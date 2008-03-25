class AddPermalinkToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :permalink, :string, :null => false
    add_index :photos, :permalink
  end

  def self.down
    remove_column :photos, :permalink
  end
end
