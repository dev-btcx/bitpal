class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end     

  def create
    @merchant = Merchant.find_by_email(params[:session][:email])
    if @merchant && @merchant.authenticate(params[:session][:password])
		  sign_in @merchant
		  redirect_to merchant_path(@merchant)
    else
      gflash :warning => { :nodom_wrap => true }
      render "/pages/index"
    end
  end	     

  def destroy
    sign_out
    redirect_to root_path
  end
end