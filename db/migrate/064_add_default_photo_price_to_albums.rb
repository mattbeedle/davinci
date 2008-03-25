class AddDefaultPhotoPriceToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :default_photo_price, :float, :default => 0.0, :null => false
    Album.find(:all).each do |album|
      album.update_attribute :default_photo_price, 0.0
    end
  end

  def self.down
    remove_column :albums, :default_photo_price
  end
end
