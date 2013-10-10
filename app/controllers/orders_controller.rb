require 'bitcoin'
require 'digest/sha2'
require 'uri'
require 'net/http'

class OrdersController < ApplicationController
  before_filter :correct_user, :only => [:index, :update]
  include SessionsHelper  
  
  #time duration in minutes
  HOUR = 60
  DAY = 1440      
  
  def index
    @merchant = Merchant.find(params[:id])
    @orders = Order.where("merchant_id = ?", @merchant.id).page(params[:page]).per(5)   
    @current_page = params[:page]            
  end
  
  def show
    begin
      # find merchant with merchant_id paramter from incoming request
	  @order = Order.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        gflash :warning => { :value => "Order with such id was not found!", :nodom_wrap => true }
        redirect_to :root	
    end         
  end 
  
  # to finish pending order
  def update
    @order = Order.find(params[:id])    
    if (@order.status == :PENDING)
      @order.status = :FINISHED 
      @order.save           
      render :json => @order.as_json(:only => [:id])
    end     
  end
    
  def new       
    # request from live site
    is_demo = false
               
    begin
      # find merchant with merchant_id paramter from incoming request
      merchant = Merchant.find(params[:merchant_id])  
    rescue ActiveRecord::RecordNotFound
      render_show_address(params["output_type"], nil, "Merchant with such id was not found!") and return
    end     
    
	if (!is_demo)
		# calculate signature using 'number' paramter from incoming request and merchant's api_key
		@generated_signature = get_sha512_hash(params[:number], merchant.api_key)
		# signature from incoming request
		@incoming_signature = params["signature"]
		# compare signature from incoming request and generated signature
		if (@incoming_signature != @generated_signature)
		  render_show_address(params["output_type"], nil, "Signature incorrect!") and return      
		end	
	end

    # signatures are equal - request came from trusted merchant, let's check order
    @order = Order.where("number = ? and merchant_id = ?", params[:number], params[:merchant_id] ).first
    # check if Order already exists
    if (@order != nil)      
      render_show_address(params["output_type"], nil, "Order with such order id is already exists!") and return                       
    end

    begin
      # order is absent, create new one in our system
      @order = Order.new
  
      # run bitcoin client
      client = Bitcoin::Client.new(BitcoinApp::Application.config.user,
                                   CGI.escape(BitcoinApp::Application.config.password),
                                   :host => BitcoinApp::Application.config.host,
                                   :port => BitcoinApp::Application.config.port)
                                                                      
      # generate fresh address for new order
      @order.bitcoin_address = is_demo ? "1Pg7dTRGJRmZmWKEMK3xhppq574eytZSxG": client.getnewaddress	  
          
      # pass all paramters from incoming request to order object
      @order.number = params["number"]
      @order.description = params["description"]
      @order.amount = params["amount"].to_f      
      @order.result_url = params["result_url"]
      @order.postback_url = params["postback_url"]
      @order.merchant_id = params["merchant_id"]    
      @order.status = :NEW
      @order.save                         
    rescue ActiveRecord::ActiveRecordError
      render_show_address(params["output_type"], nil, "Error during saving record into DB!") and return            
    rescue Errno::ECONNREFUSED
      render_show_address(params["output_type"], nil, "Couldn't connect to bitcoin daemon!") and return                 
    end  
                    
    render_show_address(params["output_type"], @order, "")    
  end
    
  def check_new       
    @count_new = 0;
    @count_pending = 0;
    @count_expired = 0;     
        
    orders = Order.where("status = ?", Order.status(:NEW))
    
    orders.each do |order|      
      @count_new += 1
      
      # get received amount immediatly
	  amount_received, income = get_payment_data(order, 0)       
      if (income > 0)
        ActiveRecord::Base.transaction do                        
          make_payment(order, income) 
          order.status = :PENDING
          order.save 
        end      
      end   
          
      if (order.status == :PENDING)
        send_postback_request(order, "Bitpal: order is pre-confirmed, you can pack the parcel on the warehouse")
        @count_pending += 1         
      end      
                       
      # check if order is expired (the order should be done during the first 60 minutes after generating address)            
      valid_interval = (Time.now.utc - order.created_at) / 60
      if (order.status == :NEW && valid_interval > HOUR)
        order.status = :EXPIRED
        order.save
        @count_expired += 1
      end                                 
    end        
  end
  
  def check_pending     
    @count_pending = 0;
    @count_finished = 0;
    @count_unfinished = 0;
    @count_canceled = 0;
        
    orders = Order.where(:status => [Order.status(:PENDING)])
    
    orders.each do |order|      
      @count_pending += 1
      
      # get received amount after 4 confirmations                
      amount_received, income = get_payment_data(order, 4)	                                          
      ActiveRecord::Base.transaction do       
        make_payment(order, income) if (income > 0)
        if (amount_received > 0)
          order.status = amount_received == order.amount ? :FINISHED : :PENDING
          order.save                 
        end
      end             
           
      # check if order should be canceled (the hole order should be done during the 24 hours after receiving first money)            
      valid_interval = (Time.now.utc - order.created_at) / 60
      if (order.status == :PENDING && valid_interval > DAY)
        order.status = :CANCELED
        order.save
      end  

      count_finished, count_unfinished, count_canceled = change_status(order)
      
      @count_finished += count_finished
      @count_unfinished += count_unfinished
      @count_canceled += count_canceled                                                                                                       
    end      
  end        

 def check_expired         
    @count_expired = 0;
    @count_pending = 0;
    @count_canceled = 0;
    @count_finished = 0;
    
    orders = Order.where("status = ?", Order.status(:EXPIRED))
    
    orders.each do |order|      
      @count_expired += 1
      
      # still waiting for money                 
      amount_received, income = get_payment_data(order, 0)     
      ActiveRecord::Base.transaction do
        make_payment(order, income) if (income > 0)
        if (amount_received > 0)           
          order.status = amount_received == order.amount ? :FINISHED : :PENDING          
          order.save                   
        end
      end     

      # check if Order should be cancelled expired (if we have not received any money during the 24 hours)            
      valid_interval = (Time.now.utc - order.created_at) / 60
      if (order.status == :EXPIRED && valid_interval > DAY)
        order.status = :CANCELED
        order.save
      end
                          
      count_finished, count_pending, count_canceled = change_status(order)
      
      @count_finished += count_finished
      @count_pending += count_pending
      @count_canceled += count_canceled                                                  
    end      
  end
  
  private

  def render_show_address(output_type, order, error_message)
    if (output_type != nil && output_type  == "json")
      render :json => { :order => order, :error_message => error_message}.as_json
    elsif (output_type != nil && output_type  == "iframe")
      @error_message = error_message
      render 'show_address_iframe', :layout => false
    else 
      @error_message = error_message
      render 'show_address'
    end     
  end
  
  def change_status(order)
    count_finished, count_pending, count_canceled = 0, 0, 0
    if (order.status == :FINISHED)
      send_postback_request(order, "Bitpal: order is confirmed, you can send the parcel to the buyer")
      count_finished += 1  
    elsif (order.status == :PENDING)
      send_postback_request(order, "Bitpal: order is pre-confirmed, you can pack the parcel on the warehouse. Total amount received: " + order.received_amount.to_s + "BTC. Order amount: "+ order.amount.to_s + "BTC.")
      count_pending += 1
    elsif (order.status == :CANCELED)
      send_postback_request(order, "Bitpal: order has been expired and cancelled. Total amount received: " + order.received_amount.to_s + "BTC. Order amount: "+ order.amount.to_s + "BTC")                     
      count_canceled += 1
    end
    return count_finished, count_pending, count_canceled   
  end      
  
  def send_postback_request(order, message)
    merchant = Merchant.find(order.merchant_id)
    params = {
      'order_id' => order.number,
      'signature' => get_sha512_hash(order.number, merchant.api_key),
      'status' => order.status,
      'message' => message
    }          
    uri = URI(order.postback_url)
    req = Net::HTTP::Post.new(uri.to_s)
    req.set_form_data(params)    
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end         
  end
  
  def get_payment_data(order, confirmations)
    received = get_amount(order, confirmations)      
    income = received - order.received_amount.to_f
	return received, income	  
  end
  
  def get_amount(order, minconf)
    client = Bitcoin::Client.new(BitcoinApp::Application.config.user,
                                 CGI.escape(BitcoinApp::Application.config.password),
                                 :host => BitcoinApp::Application.config.host,
                                 :port => BitcoinApp::Application.config.port)                                                                                 
    amount_received = 0
    begin                                    
      amount_received = client.getreceivedbyaddress(order.bitcoin_address, minconf)
    rescue Errno::ENETUNREACH 
      logger.error "Couldn't get amount for address #{order.bitcoin_address} from bitcoin network for order #{order.id}. Problem with network"                   
    end  
    return amount_received                                       
  end

  def make_payment(order, delta)       
	ActiveRecord::Base.transaction do
		transaction = InternalTransaction.new
		transaction.action_type = :PAYMENT
		transaction.merchant_id = order.merchant_id
		transaction.amount = delta
		transaction.save  
		payment = Payment.new
		payment.order_id = order.id
		payment.internal_transaction_id = transaction.id
		payment.save
	end
  end
    
  def get_sha512_hash(*s)
    Digest::SHA512.hexdigest(s.join(':'))
  end    
  
end
