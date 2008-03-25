class AddUpdatedAndCreatedAtToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :created_at, :datetime
    add_column :photos, :updated_at, :datetime
  end

  def self.down
    remove_column :photos, :created_at
    remove_column :photos, :updated_at
  end
end
