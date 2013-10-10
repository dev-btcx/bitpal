class Payment < ActiveRecord::Base
	belongs_to :order
	belongs_to :internal_transaction
end
