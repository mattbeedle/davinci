class AddCustomisationOptionsToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :clean, :boolean, :default => false, :null => false
    add_column :albums, :camera_info, :boolean, :default => false, :null => false
    add_column :albums, :display_filenames, :boolean, :default => false, :null => false
    add_column :albums, :sort_by, :string, :limit => 10, :default => 'position', :null => false
    add_column :albums, :sort_direction, :string, :limit => 4, :default => 'DESC', :null => false
    Album.find(:all).each do |album|
      album.update_attribute :clean, false
      album.update_attribute :camera_info, false
      album.update_attribute :display_filenames, false
      album.update_attribute :sort_by, 'position'
      album.update_attribute :sort_direction, 'DESC'
    end
  end

  def self.down
    remove_column :albums, :clean
    remove_column :albums, :camera_info
    remove_column :albums, :display_filenames
    remove_column :albums, :sort_by
    remove_column :albums, :sort_direction
  end
end
