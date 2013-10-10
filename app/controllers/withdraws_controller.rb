class WithdrawsController < ApplicationController
  before_filter :correct_user, :only => :index
  include SessionsHelper        

  # minimal amount to withdraw - 0.01BTC
  MINIMAL_AMOUNT = BigDecimal.new("0.01")
  # withdraw fee percent - 1%
  WITHDRAW_FEE_PERCENT = BigDecimal.new("0.01")
  # bitcoin fee - 0.0005BTC
  BITCOIN_FEE = BigDecimal.new("0.0005")
      
	def index
		@merchant = Merchant.find(params[:id])
		@withdraws = Withdraw.where("merchant_id = ?", @merchant.id)		
	end
	
  def create    	
	amount = params[:withdraw][:amount].to_f
    merchant = current_user        
	
    if ((amount >= MINIMAL_AMOUNT) && (amount <= merchant.balance))            		  
    
	  begin
        ActiveRecord::Base.transaction do
          create_withdraw(merchant, amount)
        end      
        gflash :success => { :nodom_wrap => true }
      rescue RestClient::InternalServerError
        logger.error "Couldn't perform the withdraw #{amount}BTC to address #{merchant.bitcoin_address} for user #{merchant.id}"
        gflash :warning => { :value => "The error occured on the server. We will try to fix it ASAP!", :nodom_wrap => true }
      rescue Errno::ECONNREFUSED
        gflash :warning => { :value => "Couldn't connect to bitcoin daemon. Please, try to withdraw later!", :nodom_wrap => true }
      end
              
    else
      gflash :warning => { :value => "not enough money on your balance", :nodom_wrap => true }
    end         
    redirect_to "/merchants/"+merchant.id.to_s+"/withdraws"
  end  
  	  
  private
      
    def perform_withdraw(bitcoin_address, amount)            
      client = Bitcoin::Client.new(BitcoinApp::Application.config.user,
                                   CGI.escape(BitcoinApp::Application.config.password),
                                   :host => BitcoinApp::Application.config.host,
                                   :port => BitcoinApp::Application.config.port)                                                                                 
      client.sendtoaddress(bitcoin_address, amount.to_f)                                 
    end
      
    def create_withdraw(merchant, amount)
      commission_fee = amount * WITHDRAW_FEE_PERCENT   
	  amount_to_send = amount - commission_fee - BITCOIN_FEE
	  
      #create internal transaction
	  transaction = InternalTransaction.new
      transaction.action_type = :WITHDRAW
      transaction.merchant_id = merchant.id
      transaction.amount = -amount
      transaction.save  
	  
	  #create withdraw
	  withdraw = Withdraw.new
	  withdraw.amount = amount_to_send
	  withdraw.fee = BITCOIN_FEE
	  withdraw.commission = commission_fee	  
	  withdraw.merchant_id = merchant.id
	  withdraw.internal_transaction_id = transaction.id
	  withdraw.save	  	  
	  
      perform_withdraw(merchant.bitcoin_address, amount_to_send)	  
    end	
end
