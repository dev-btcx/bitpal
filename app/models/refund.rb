class Refund < ActiveRecord::Base
  belongs_to :order
  belongs_to :internal_transaction
  attr_accessible :amount, :bitcoin_address  
end
