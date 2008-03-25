class Size < ActiveRecord::Base
  has_many :product_sizes
  has_many :products,
    :through => :product_sizes,
    :dependent => :nullify

  validates_presence_of :name
end
