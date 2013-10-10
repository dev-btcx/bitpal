class Merchant < ActiveRecord::Base	
	
	has_many :orders
	has_many :withdraws
	has_many :internal_transactions

	attr_accessible :name, :email, :password, :password_confirmation, :bitcoin_address

	has_secure_password  

	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :bitcoin_address, :presence => true,
			:length   => { :maximum => 50 }

	validates :email, :presence => true,
					:format   => { :with => email_regex },
					:uniqueness => { :case_sensitive => false }  

	validates_presence_of :password, :on => :create
	validates_presence_of :password_confirmation, :on => :create

    def balance
		InternalTransaction
		.joins("LEFT OUTER JOIN payments on payments.internal_transaction_id = internal_transactions.id")
		.where("payments.order_id in (select orders.id from orders where orders.merchant_id = ? and orders.status = 3) OR payments.order_id is null", read_attribute(:id))
		.where("internal_transactions.merchant_id = ?", read_attribute(:id))		
		.sum("internal_transactions.amount")      
    end     

end
