class AddPermalinkToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :permalink, :string, :null => false
    add_index :albums, :permalink
  end

  def self.down
    remove_column :albums, :permalink
  end
end
