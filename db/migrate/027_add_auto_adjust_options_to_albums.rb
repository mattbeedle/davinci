class AddAutoAdjustOptionsToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :unsharp_radius, :float, :null => false, :default => 0.0
    add_column :albums, :unsharp_sigma, :float, :null => false, :default => 1.0
    add_column :albums, :unsharp_amount, :float, :null => false, :default => 1.0
    add_column :albums, :unsharp_threshold, :float, :null => false, :default => 0.05
    for album in Album.find(:all)
      album.unsharp_radius = 0.0
      album.unsharp_sigma = 1.0
      album.unsharp_amount = 1.0
      album.unsharp_threshold = 0.05
    end
  end

  def self.down
    remove_column :albums, :unsharp_radius
    remove_column :albums, :unsharp_sigma
    remove_column :albums, :unsharp_amount
    remove_column :albums, :unsharp_threshold
  end
end
