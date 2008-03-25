class Product < ActiveRecord::Base

  has_many :product_sizes
  has_many :sizes,
    :through => :product_sizes,
    :dependent => :nullify

  validates_presence_of :name
  validates_numericality_of :price, :weight

  def to_param
    self.name
  end
end
