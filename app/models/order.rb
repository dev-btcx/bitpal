class Order < ActiveRecord::Base
	include ActiveUUID::UUID

	belongs_to :merchant
	attr_accessible :bitcoin_address, :number, :description, :amount, :result_url, :postback_url, :merchant_id

	STATUS = { NEW: 1, PENDING: 2, FINISHED: 3, EXPIRED: 4, CANCELED: 5 }

	def status
		STATUS.key(read_attribute(:status))
	end

	def status=(s)
		write_attribute(:status, STATUS[s])
	end  

	def self.status(s) 
		STATUS[s]
	end

    def refund_amount
		InternalTransaction
		.where("internal_transactions.id in 
				(SELECT payments.internal_transaction_id FROM `payments` left join orders on orders.id = payments.order_id WHERE orders.id = ? 
					UNION
				SELECT refunds.internal_transaction_id FROM `refunds` left join orders on orders.id = refunds.order_id WHERE orders.id = ?)", read_attribute(:id), read_attribute(:id))
		.sum("internal_transactions.amount") 
    end     
	
    def received_amount
		Payment.joins("LEFT OUTER JOIN internal_transactions on internal_transactions.id = payments.internal_transaction_id")
		.joins("LEFT OUTER JOIN orders on orders.id = payments.order_id")
		.where("orders.id = ?", read_attribute(:id))		
		.sum("internal_transactions.amount")      
    end 	
end
