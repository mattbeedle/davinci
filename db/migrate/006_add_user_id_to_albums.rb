class AddUserIdToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :user_id, :integer, :null => false
    add_index :albums, :user_id
  end

  def self.down
    remove_column :albums, :user_id
  end
end
