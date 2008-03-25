class CreateOrderAddresses < ActiveRecord::Migration
  def self.up
    create_table :order_addresses do |t|
      t.boolean :is_shipping, :null => false, :default => false
      t.string :first_name, :limit => 50
      t.string :last_name, :limit => 50
      t.string :telephone, :limit => 20
      t.string :street, :null => false
      t.string :locality, :limit => 50
      t.string :region, :limit => 20
      t.string :postal_code, :limit => 10
      t.integer :country_id, :null => false

      t.timestamps
    end
    add_index :order_addresses, [:first_name, :last_name]
  end

  def self.down
    drop_table :order_addresses
  end
end
