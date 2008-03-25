require 'RMagick'
class AddWidthAndHeightToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :height, :integer, :null => false
    add_column :photos, :width, :integer, :null => false
    Photo.find(:all).each do |photo|
      image = Magick::Image.from_blob(photo.data).first
      photo.update_attribute :height, image.rows
      photo.update_attribute :width, image.columns
    end
  end

  def self.down
    remove_column :photos, :height
    remove_column :photos, :width
  end
end
