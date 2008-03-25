class OrderLineItem < ActiveRecord::Base
  belongs_to :item,
    :class_name => 'Product',
    :foreign_key => 'product_id'
  belongs_to :photo
  belongs_to :order

  validates_presence_of :product_id, :order_id, :quantity, :unit_price, :photo_id
  validates_numericality_of :quantity, :unit_price

  alias_attribute :price, :unit_price
  # Creates and returns a line item when a product is passed in
  def self.for_product(item, photo)
    ol_item = self.new
    ol_item.quantity = 1
    ol_item.item = item
    ol_item.photo_id = photo.id # Manually adding the id, instead of entire photo to avoid session overflow
    #ol_item.name = item.name
    ol_item.unit_price = item.price
    ol_item
  end

  def total
    self.quantity * self.unit_price
  end
  
  def product
    self.item
  end
  
  def code
    self.item.code
  end
  
  def name
    if !self.item.nil?
      return self.item.name
    else
      return self.attributes['name']
    end
  end
end
