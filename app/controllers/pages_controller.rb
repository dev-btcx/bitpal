class PagesController < ApplicationController

  def index
    render 'index', :layout => 'welcome'
  end

  def registration
    @merchant = Merchant.new
    render 'registration', :layout => 'welcome'
  end
end
