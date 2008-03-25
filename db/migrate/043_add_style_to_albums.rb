class AddStyleToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :style, :string
  end

  def self.down
    remove_column :albums, :style
  end
end
