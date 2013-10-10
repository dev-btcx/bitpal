class InternalTransaction < ActiveRecord::Base
  belongs_to :merchant
  attr_accessible :amount, :action_type, :merchant_id, :payment_id, :withdraw_id, :bitcoin_address
  
  ACTION_TYPE = { PAYMENT: 1, WITHDRAW: 2, BITPAL_FEE: 3, BITCOIN_FEE: 4, REFUND: 5 }

  def action_type
    ACTION_TYPE.key(read_attribute(:action_type))
  end

  def action_type=(s)
    write_attribute(:action_type, ACTION_TYPE[s])
  end  
  
  def self.action_type(s) 
    ACTION_TYPE[s]
  end
  
end
