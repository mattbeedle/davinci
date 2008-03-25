class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :sender_id, :null => false
      t.string :code, :null => false
      t.string :receiver_name, :null => false
      t.string :receiver_email, :null => false

      t.timestamps
    end
    add_index :invitations, :code
  end

  def self.down
    drop_table :invitations
  end
end
