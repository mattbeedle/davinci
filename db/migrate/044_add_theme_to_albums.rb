class AddThemeToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :theme, :string
  end

  def self.down
    remove_column :albums, :theme
  end
end
