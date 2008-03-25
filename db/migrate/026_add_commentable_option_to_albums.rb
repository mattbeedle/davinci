class AddCommentableOptionToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :commentable, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :albums, :commentable
  end
end
