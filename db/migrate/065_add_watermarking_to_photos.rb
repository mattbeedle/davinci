class AddWatermarkingToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :watermarked_photo_id, :integer
    add_column :photos, :is_watermarked, :boolean, :default => false, :null => false
    Photo.find(:all).each do |photo|
      photo.update_attribute :is_watermarked, false
    end
  end

  def self.down
    remove_column :photos, :watermarked_photo_id
  end
end
