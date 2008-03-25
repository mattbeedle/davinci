class AddOrderAccountIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :order_account_id, :integer
  end

  def self.down
    remove_column :orders, :order_account_id
  end
end
