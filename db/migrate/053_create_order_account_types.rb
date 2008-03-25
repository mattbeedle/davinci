class CreateOrderAccountTypes < ActiveRecord::Migration
  def self.up
    create_table :order_account_types do |t|
      t.string :name, :limit => 30, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :order_account_types
  end
end
