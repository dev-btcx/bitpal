class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders, :id => false do |t|
		t.uuid :id, :primary_key => true
		t.string :bitcoin_address, :limit => 50, :null => false
		t.string :number, :limit => 255, :null => false
		t.string :description, :limit => 255, :null => false
		t.decimal :amount, :precision => 18, :scale => 8, :default => 0, :null => false	 
		t.integer :status, :default => 1, :null => false 
		t.string :result_url, :limit => 255, :null => false
		t.string :postback_url, :limit => 255, :null => false
		t.references :merchant, :null => false  # belongs_to :merchant
		t.foreign_key :merchants
		t.timestamps
    end	
    add_index :orders, :id
  end

  def self.down	
    drop_table :orders
  end
end
