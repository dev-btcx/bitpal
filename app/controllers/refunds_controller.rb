class RefundsController < ApplicationController  
  # minimal amount to withdraw - 0.01BTC
  MINIMAL_AMOUNT = BigDecimal.new("0.0005")
  # bitcoin fee - 0.0005BTC
  BITCOIN_FEE = BigDecimal.new("0.0005") 
      

  def new     
    @order = Order.find(params[:id]) 
	@refunds = Refund.where("order_id = ?", @order.id)
  end
    	
  def create  
  
	begin
	  # probably somebody will try to refund miney from another payment!
	  order = Order.find(params[:refund][:order_id])      
	rescue ActiveRecord::RecordNotFound                          
	  gflash :warning => { :value => "Order with such id was not found", :nodom_wrap => true }
	  redirect_to root_path and return        
	end   

	# attempt to refund money from payment, which is in progress!
	if (order.status != :CANCELED || order.received_amount == 0)
      gflash :warning => { :value => "This order in progress now. You can not refund it!", :nodom_wrap => true }
	  redirect_to root_path and return                        
	end                
	
    bitcoin_address = params[:refund][:bitcoin_address]
	amount = params[:refund][:amount].to_f
    
    if (bitcoin_address.length == 0)           
      gflash :warning => { :value => "You should insert bitcoin address", :nodom_wrap => true }          
      redirect_to "/orders/"+order.id.to_s+"/refund" and return      
    end
    	  	 
    if ((amount <= BITCOIN_FEE) || (amount > order.refund_amount))           
      gflash :warning => { :value => "Not enough money to perform refund", :nodom_wrap => true }          
      redirect_to "/orders/"+order.id.to_s+"/refund" and return           
    end                   
    
    begin                
      ActiveRecord::Base.transaction do        
        create_refund(bitcoin_address, order, amount)     
      end
  	  gflash :success => { :nodom_wrap => true }
    rescue RestClient::InternalServerError
      @error = "The error occured on the server. We will try to fix it ASAP!"
      logger.error "Couldn't perform the refund of #{amount}BTC to addres #{bitcoin_address}"
      gflash :warning => { :value => @error, :nodom_wrap => true }
      redirect_to "/orders/"+order.id.to_s+"/refund" and return
    rescue Errno::ECONNREFUSED
      @error = "Couldn't connect to bitcoin daemon. Please, try to withdraw later!"
      gflash :warning => { :value => @error, :nodom_wrap => true }
      redirect_to "/orders/"+order.id.to_s+"/refund" and return
    end	  	       
  end  
  	  
  private          
    def perform_refund(bitcoin_address, amount)       
      client = Bitcoin::Client.new(BitcoinApp::Application.config.user,
                                   CGI.escape(BitcoinApp::Application.config.password),
                                   :host => BitcoinApp::Application.config.host,
                                   :port => BitcoinApp::Application.config.port)                                                                                 
      client.sendtoaddress(bitcoin_address, amount.to_f)                                        
    end
      
    def create_refund(bitcoin_address, order, amount)
	  amount_to_send = amount - BITCOIN_FEE
	
      #create internal transaction
	  transaction = InternalTransaction.new
      transaction.action_type = :REFUND
      transaction.merchant_id = order.merchant_id
      transaction.amount = -amount
      transaction.save  
	  
	  #create withdraw
	  refund = Refund.new
	  refund.amount = amount_to_send
	  refund.fee = BITCOIN_FEE
	  refund.order_id = order.id
	  refund.bitcoin_address = bitcoin_address
	  refund.internal_transaction_id = transaction.id
	  refund.save	

	  # perform_refund(bitcoin_address, amount_to_send)	  
    end             
end
