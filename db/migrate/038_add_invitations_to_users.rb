class AddInvitationsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sent_invitations, :integer, :null => false, :default => 0
    add_column :users, :redeemed_invitations, :integer, :null => false, :default => 0
    add_column :users, :invited_by_id, :integer
    User.find(:all).each do |user|
      user.update_attribute :sent_invitations, 0
    end
  end

  def self.down
    remove_column :users, :sent_invitations
    remove_column :users, :redeemed_invitations
    remove_column :users, :invited_by_id
  end
end
