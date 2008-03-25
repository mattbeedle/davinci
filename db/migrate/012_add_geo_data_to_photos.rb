class AddGeoDataToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :street, :string
    add_column :photos, :region, :string
    add_column :photos, :locality, :string
    add_column :photos, :postal_code, :string
  end

  def self.down
    remove_column :photos, :street
    remove_column :photos, :region
    remove_column :photos, :locality
    remove_column :photos, :postal_code
  end
end
