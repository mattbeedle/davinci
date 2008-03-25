class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      # remove the below line if you want to store image data via the file system instead of the database
      t.column :data, :binary, :size => 10_000_000, :null => false
      
      #Add other fields here
      t.column :name, :string
      t.column :original_filename, :string, :null => false
      t.column :content_type, :string, :null => false
      t.column :user_id, :integer, :null => false
      t.column :lat, :float
      t.column :lng, :float
    end
    add_index :photos, :user_id
    
    # remove the below line if you want to store image data via the file system instead of the database
    execute "ALTER TABLE `photos` MODIFY `data` MEDIUMBLOB"
  end

  def self.down
    drop_table :photos
  end
end
