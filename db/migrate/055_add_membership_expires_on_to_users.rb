class AddMembershipExpiresOnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :membership_expires_on, :date
    User.find(:all).each do |user|
      if not user.last_paid_at.blank?
        user.update_attribute :membership_expires_on, user.last_paid_at + 1.year
      elsif not user.trial_started_at.blank?
        user.update_attribute :membership_expires_on, user.trial_started_at + APP_CONFIG['trial_length'].days 
      end
    end
  end

  def self.down
    remove_column :users, :membership_expires_on
  end
end
