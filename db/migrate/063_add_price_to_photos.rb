class AddPriceToPhotos < ActiveRecord::Migration
  def self.up
    Photo.drop_versioned_table
    add_column :photos, :price, :float, :default => 0.0, :null => false
    Photo.create_versioned_table
    Photo.find(:all).each do |photo|
      photo.update_attribute :price, 0.0
    end
  end

  def self.down
    Photo.drop_versioned_table
    remove_column :photos, :price
    Photo.create_versioned_table
  end
end
