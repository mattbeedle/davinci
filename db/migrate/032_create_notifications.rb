class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :sender_id, :null => false
      t.integer :receiver_id, :null => false
      t.integer :notification_type_id, :null => false
      t.integer :notifyable_id, :null => false
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :sender_id
    add_index :notifications, :receiver_id
  end

  def self.down
    drop_table :notifications
  end
end
