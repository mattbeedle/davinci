class AddFeaturedToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :featured, :boolean, :null => false, :default => 0
    Album.find(:all).each do |album|
      album.update_attribute :featured, 0
    end
    add_index :albums, :featured
  end

  def self.down
    remove_column :albums, :featured
  end
end
