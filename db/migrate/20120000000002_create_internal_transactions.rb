class CreateInternalTransactions < ActiveRecord::Migration
  def change
    create_table :internal_transactions do |t|	
		t.integer :action_type, :default => 0, :null => false 
		t.decimal :amount, :precision => 18, :scale => 8, :default => 0, :null => false		
		t.references :merchant, :null => false  # belongs_to :merchant
		t.foreign_key :merchants		
		t.timestamps
    end	
  end
end
