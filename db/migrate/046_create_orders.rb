class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.datetime :shipped_on
      t.integer :user_id, :null => false
      t.integer :order_status_code_id, :null => false, :default => 1
      t.text :notes
      t.string :referer
      t.integer :order_shipping_type_id, :null => false, :default => 1
      t.float :product_cost, :default => 0.0
      t.float :shipping_cost, :default => 0.0
      t.float :tax, :limit => 5

      t.timestamps
    end
    add_index :orders, :user_id
    add_index :orders, :order_status_code_id
  end

  def self.down
    drop_table :orders
  end
end
