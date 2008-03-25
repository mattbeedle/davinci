class CreateOrderAccounts < ActiveRecord::Migration
  def self.up
    create_table :order_accounts do |t|
      t.integer :order_account_type_id, :null => false, :default => 1
      t.string :cc_number, :string, :limit => 17
      t.string :account_number, :limit => 20
      t.integer :expiration_month, :limit => 2
      t.integer :expiration_year, :limit => 4
      t.integer :credit_ccv, :limit => 5
      t.string :routing_number, :limit => 20
      t.string :bank_name, :limit => 50

      t.timestamps
    end
    add_index :order_accounts, :order_account_type_id, :name => :ids
  end

  def self.down
    drop_table :order_accounts
  end
end
