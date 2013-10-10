class PaymentsController < ApplicationController
  before_filter :correct_user
  include SessionsHelper  
  
  def index
    @order = Order.find(params[:order_id])
    @payments = Payment.where("order_id = ?", @order.id).page(params[:page]).per(5)   
    @current_page = params[:page]            
  end  
end
