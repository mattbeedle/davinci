class AddTrialAndPaymentDatesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :trial_started_at, :datetime
    add_column :users, :last_paid_at, :datetime
  end

  def self.down
    remove_column :users, :trial_started_at
    remove_column :users, :last_paid_at
  end
end
