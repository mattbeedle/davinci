class CreateOrderUsers < ActiveRecord::Migration
  def self.up
    create_table :order_users do |t|
      t.string :username, :limit => 50
      t.string :email, :limit => 100, :null => false
      t.string :password_salt, :limit => 40, :null => false
      t.string :password_hash, :limit => 40, :null => false
      t.integer :user_id

      t.timestamps
    end
    add_index :order_users, :email
    add_index :order_users, :user_id
  end

  def self.down
    drop_table :order_users
  end
end
