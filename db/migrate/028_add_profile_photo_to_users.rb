class AddProfilePhotoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_photo_id, :integer
  end

  def self.down
    remove_column :users, :profile_photo_id
  end
end
