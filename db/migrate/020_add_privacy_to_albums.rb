class AddPrivacyToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :privacy_type, :string, :default => 'public', :null => false
    add_column :albums, :salt, :string, :limit => 40
    add_column :albums, :crypted_password, :string, :limit => 40
    add_index :albums, :privacy_type
    for album in Album.find(:all)
      album.update_attribute :privacy_type, 'public'
    end
  end

  def self.down
    remove_column :albums, :privacy_type
    remove_column :albums, :salt
    remove_column :albums, :crypted_password
  end
end
