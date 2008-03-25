class AddFeaturedToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :featured, :boolean, :default => false, :null => false
    add_index :photos, :featured
    Photo.find(:all).each do |photo|
      photo.update_attribute :featured, false
    end
  end

  def self.down
    remove_column :photos, :featured
  end
end
