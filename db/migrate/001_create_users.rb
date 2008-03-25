class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime

      # Custom
      t.column :forename, :string
      t.column :surname, :string
      t.column :street, :string
      t.column :locality, :string
      t.column :region, :string
      t.column :postal_code, :string
      t.column :born_on, :date
    end
  end

  def self.down
    drop_table "users"
  end
end
