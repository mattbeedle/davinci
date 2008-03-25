class AddHomepageContentPreferencesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :homepage_content_preferences, :text, :null => false
    User.find(:all).each do |user|
      preferences = { :news => "display", :welcome => "display", :bio => "display", :featured_albums => "display", 
        :relationships => "display", :groups => "display", :tags => "display", :albums => "display" }
      user.update_attribute :homepage_content_preferences, preferences
    end
  end

  def self.down
    remove_column :users, :homepage_content_preferences
  end
end
