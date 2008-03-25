class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name, :null => false
      t.text :description
      t.float :price, :null => false, :default => 0.0, :limit => 10
      t.float :weight, :null => false, :default => 0.0, :limit => 10

      t.timestamps
    end
    add_index :products, :name
  end

  def self.down
    drop_table :products
  end
end
