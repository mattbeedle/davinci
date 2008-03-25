class OrderAddress < ActiveRecord::Base
  belongs_to :country
  has_many :shipping_address_orders,
    :class_name => 'Order',
    :foreign_key => 'shipping_address_id',
    :dependent => :nullify
  has_many :billing_address_orders,
    :class_name => 'Order',
    :foreign_key => 'billing_address_id',
    :dependent => :nullify

  validates_presence_of :street, :postal_code, :country_id
  validates_numericality_of :country_id
  validates_uniqueness_of :postal_code, :scope => :street
  # TODO This validation only works for uk postcodes, something more complex will be required
  # now that there are multiple countries
  validates_format_of :postal_code, 
    :with => /[A-PR-UWYZ][A-HK-Y0-9][A-HJKSTUW0-9]?[ABEHMNPRVWXY0-9]? {1,2}[0-9][ABD-HJLN-UW-Z]{2}/
end
