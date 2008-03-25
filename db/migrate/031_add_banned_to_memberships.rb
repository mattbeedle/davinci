class AddBannedToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :banned_at, :datetime
    add_column :memberships, :banned_by_id, :integer
  end

  def self.down
    remove_column :memberships, :banned_at
    remove_column :memberships, :banned_by_id
  end
end
