class CreateWithdraws < ActiveRecord::Migration
  def self.up
    create_table :withdraws do |t|
		t.decimal :amount, :precision => 18, :scale => 8, :default => 0, :null => false
		t.decimal :fee, :precision => 18, :scale => 8, :default => 0, :null => false
		t.decimal :commission, :precision => 18, :scale => 8, :default => 0, :null => false
		t.references :merchant, :null => false  # belongs_to :merchant
		t.foreign_key :merchants
		t.references :internal_transaction, :null => false  # belongs_to :internal_transaction
		t.foreign_key :internal_transactions		
		t.timestamps
    end	    
  end

  def self.down	
    drop_table :withdraws
  end
end
