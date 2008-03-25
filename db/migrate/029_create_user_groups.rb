class CreateUserGroups < ActiveRecord::Migration
  def self.up
    create_table :user_groups do |t|
      t.string :name, :null => false
      t.text :description
      t.string :group_type, :null => false, :default => 'public'
      t.integer :photo_id
      t.string :permalink, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :user_groups
  end
end
