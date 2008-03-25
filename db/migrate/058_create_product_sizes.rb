class CreateProductSizes < ActiveRecord::Migration
  def self.up
    create_table :product_sizes do |t|
      t.integer :product_id, :null => false
      t.integer :size_id, :null => false

      t.timestamps
    end
    add_index :product_sizes, [:product_id, :size_id], :name => :ids
  end

  def self.down
    drop_table :product_sizes
  end
end
