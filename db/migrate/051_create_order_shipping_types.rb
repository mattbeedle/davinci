class CreateOrderShippingTypes < ActiveRecord::Migration
  def self.up
    create_table :order_shipping_types do |t|
      t.string :name, :null => false, :limit => 100
      t.string :code, :limit => 50
      t.string :company, :limit => 20
      t.boolean :is_domestic, :default => false, :null => false
      t.string :service_type, :limit => 50
      t.string :transaction_type, :limit => 50
      t.float :shipping_multiplier, :null => false, :limit => 10, :default => 0.0
      t.float :flat_fee, :limit => 10, :default => 0.0, :null => false

      t.timestamps
    end

    # Populate from YAML file
    YAML.load(File.open(RAILS_ROOT + '/db/order_shipping_types.yml')).each do |shipping_type|
      OrderShippingType.create shipping_type.ivars
    end
  end

  def self.down
    drop_table :order_shipping_types
  end
end
