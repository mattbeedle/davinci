class CreateMembershipsAlbums < ActiveRecord::Migration
  def self.up
    create_table :memberships_albums do |t|
      t.integer :membership_id, :null => false
      t.integer :album_id, :null => false

      t.timestamps
    end
    add_index :memberships_albums, :membership_id
    add_index :memberships_albums, :album_id
  end

  def self.down
    drop_table :memberships_albums
  end
end
