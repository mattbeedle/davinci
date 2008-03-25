class OrderAccountType < ActiveRecord::Base
  has_many :order_accounts,
    :dependent => :nullify
end
