class AddFriendAndFamilyOptionsToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :friends_edit, :boolean, :default => false, :null => false
    add_column :albums, :family_edit, :boolean, :default => false, :null => false
    Album.find(:all).each do |album|
      album.friends_edit = false
      album.family_edit = false
      album.save
    end
  end

  def self.down
    remove_column :albums, :friends_edit
    remove_column :albums, :family_edit
  end
end
