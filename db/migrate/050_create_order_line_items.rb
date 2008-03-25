class CreateOrderLineItems < ActiveRecord::Migration
  def self.up
    create_table :order_line_items do |t|
      t.integer :product_id, :null => false
      t.integer :order_id, :null => false
      t.integer :photo_id, :null => false
      t.integer :quantity, :null => false
      t.float :unit_price, :null => false, :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :order_line_items
  end
end
