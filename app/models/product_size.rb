class ProductSize < ActiveRecord::Base
  belongs_to :product
  belongs_to :size

  validates_presence_of :product_id, :size_id
  validates_numericality_of :product_id, :size_id
  validates_uniqueness_of :product_id, :scope => :size_id
end
