class CreateOrderStatusCodes < ActiveRecord::Migration
  def self.up
    create_table :order_status_codes do |t|
      t.string :name, :limit => 30, :null => false

      t.timestamps
    end
    add_index :order_status_codes, :name

    # Populate from YAML file
    YAML.load(File.open(RAILS_ROOT + '/db/order_status_codes.yml')).each do |code|
      OrderStatusCode.create code.ivars
    end
  end

  def self.down
    drop_table :order_status_codes
  end
end
