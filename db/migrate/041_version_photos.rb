class VersionPhotos < ActiveRecord::Migration
  def self.up
    Photo.create_versioned_table
  end

  def self.down
    Photo.drop_versioned_table
  end
end
