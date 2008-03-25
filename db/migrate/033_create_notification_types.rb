class CreateNotificationTypes < ActiveRecord::Migration
  def self.up
    create_table :notification_types do |t|
      t.string :name, :null => false
      t.string :subject, :null => false
      t.text :description
      t.string :notifyable_type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :notification_types
  end
end
