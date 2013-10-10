require 'digest/sha2'

class MerchantsController < ApplicationController
  include SessionsHelper

  before_filter :correct_user, :only => [:show, :edit, :update]

  def new
		@merchant = Merchant.new
	end

	def create
		@merchant = Merchant.new(params[:merchant])
		@merchant.api_key = get_sha512_hash(@merchant.bitcoin_address)
		if @merchant.save
			sign_in @merchant
			gflash :success => { :nodom_wrap => true }
			redirect_to merchant_path(@merchant)
		else
			render '/pages/registration'
		end			
	end
	
	def show
		@merchant = Merchant.find(params[:id])				
	end
	
	def edit
		@merchant = Merchant.find(params[:id])
	end

	def update
		@merchant = Merchant.find(params[:id])		
		if @merchant.update_attributes(params[:merchant])			
			gflash :success => { :nodom_wrap => true }			
			redirect_to merchant_path(@merchant)			
		else
			render 'edit'
		end			
	end

  private
    def get_sha512_hash(*s)
      Digest::SHA512.hexdigest(s.join(':'))
    end

end
