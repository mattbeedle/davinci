class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :user_group_id
      t.integer :user_id
      t.boolean :admin, :null => false, :default => false
      t.datetime :accepted_at
      t.integer :accepted_by_id
      t.datetime :invited_at
      t.integer :invited_by_id

      t.timestamps
    end
    add_index :memberships, :user_group_id
    add_index :memberships, :user_id
  end

  def self.down
    drop_table :memberships
  end
end
