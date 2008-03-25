class RemoveUserIdFromPhotos < ActiveRecord::Migration
  def self.up
    remove_column :photos, :user_id
  end

  def self.down
    add_column :photos, :user_id, :integer, :null => false
    add_index :photos, :user_id
  end
end
