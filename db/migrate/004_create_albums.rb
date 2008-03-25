class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.column :name, :string, :null => false
      t.column :description, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :albums
  end
end
