class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|		
		t.uuid :order_id, :null => false  # belongs_to :order
		t.foreign_key :orders
		t.references  :internal_transaction, :null => false  # belongs_to :internal_transaction
		t.foreign_key :internal_transactions
		t.timestamps
    end	
  end

  def self.down	
    drop_table :payments
  end
end
