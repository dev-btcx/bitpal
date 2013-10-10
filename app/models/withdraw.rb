class Withdraw < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :internal_transaction
  attr_accessible :amount
end
