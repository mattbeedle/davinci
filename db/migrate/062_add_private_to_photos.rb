class AddPrivateToPhotos < ActiveRecord::Migration
  def self.up
    Photo.drop_versioned_table
    add_column :photos, :private, :boolean, :default => false, :null => false
    Photo.create_versioned_table
    Photo.find(:all).each do |photo|
      photo.update_attribute :private, false
    end
  end

  def self.down
    Photo.drop_versioned_table
    remove_column :photos, :private
    Photo.create_versioned_table
  end
end
