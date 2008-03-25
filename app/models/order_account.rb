class OrderAccount < ActiveRecord::Base
  belongs_to :order_account_type
  has_many :orders,
    :dependent => :nullify

  validates_presence_of :cc_number, :expiration_month, :expiration_year
  validates_uniqueness_of :cc_number
end
