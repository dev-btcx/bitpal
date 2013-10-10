class CreateRefunds < ActiveRecord::Migration
  def self.up
    create_table :refunds do |t|
		t.string :bitcoin_address, :limit => 50, :null => false
		t.decimal :amount, :precision => 18, :scale => 8, :default => 0, :null => false		
		t.decimal :fee, :precision => 18, :scale => 8, :default => 0, :null => false		
		t.uuid :order_id  		# belongs_to :order
		t.foreign_key :orders
		t.references :internal_transaction, :null => false  # belongs_to :internal_transaction
		t.foreign_key :internal_transactions		
		t.timestamps
    end	    
  end

  def self.down	
    drop_table :refunds
  end
end
