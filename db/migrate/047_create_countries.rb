class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name, :limit => 100, :null => false
      t.string :fedex_code, :limit => 50
      t.string :ufsi_code, :limit => 4
      t.integer :number_of_orders, :default => 0, :null => false
    end
    add_index :countries, :number_of_orders

    # Populate from YAML file
    YAML.load(File.open(RAILS_ROOT + '/db/countries.yml')).each do |country|
      Country.create country.ivars
    end
  end

  def self.down
    drop_table :countries
  end
end
