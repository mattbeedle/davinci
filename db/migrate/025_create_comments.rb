class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :photo_id, :null => false
      t.integer :user_id, :null => false, :default => 0
      t.text :body

      t.timestamps
    end
    add_index :comments, :photo_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
