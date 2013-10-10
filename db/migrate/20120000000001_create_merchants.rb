class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|	
		t.string :email,  :limit => 50, :null => false
		t.string :bitcoin_address,  :limit => 50, :null => false
		t.string :api_key,  :limit => 255, :null => false
		t.string :password_digest,  :limit => 255, :null => false
	  
		t.timestamps
    end	
  end
end
