class AddFriendshipTypeToFriendships < ActiveRecord::Migration
  def self.up
    add_column :friendships, :friendship_type, :string, :null => false
  end

  def self.down
    remove_column :friendships, :friendship_type
  end
end
