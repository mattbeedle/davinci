class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_shipping_type
  belongs_to :order_status_code
  has_many :order_line_items,
    :dependent => :destroy
  belongs_to :shipping_address,
    :class_name => 'OrderAddress',
    :foreign_key => 'shipping_address_id'
  belongs_to :billing_address,
    :class_name => 'OrderAddress',
    :foreign_key => 'billing_address_id'
  belongs_to :order_account

  before_save :set_product_cost

  validates_associated :shipping_address, :billing_address, :order_account
  validates_presence_of :shipping_address, :if => :address_required?
  validates_presence_of :billing_address, :if => :address_required?
  validates_presence_of :order_account, :if => :address_required?

  def build_order_account(order_account_attributes = {})
    self.order_account = OrderAccount.find_by_cc_number order_account_attributes[:cc_number]

    if self.order_account.blank?

      self.order_account = OrderAccount.new order_account_attributes

    else
      self.order_account.update_attributes order_account_attributes
    end

    self.order_account
  rescue
    self.order_account = OrderAccount.new order_account_attributes
  end

  def build_billing_address(address_attributes = {})
    # If billing address already exists, use that.
    self.billing_address = OrderAddress.find_by_street_and_postal_code(address_attributes[:street],
                                                                       address_attributes[:postal_code])
    # If the billing address was not found
    if self.billing_address.blank?

      # the billing address is new
      self.billing_address = OrderAddress.new address_attributes

      # Final check:  The shipping address in memory may be the same as this address
      if not self.shipping_address.blank?
        if self.shipping_address.street == self.billing_address.street and
          self.shipping_address.postal_code == self.billing_address.postal_code
          self.billing_address = self.shipping_address
        end
      end
    else
      self.billing_address.update_attributes address_attributes
    end
    self.billing_address
  rescue
    self.billing_address = OrderAddress.new address_attributes
  end

  def build_shipping_address(address_attributes = {})
    # If shipping address already exists, use that.
    self.shipping_address = OrderAddress.find_by_street_and_postal_code(address_attributes[:street],
                                                                        address_attributes[:postal_code])

    # If the shipping address was not found
    if self.shipping_address.blank?

      # the shipping address is new
      self.shipping_address = OrderAddress.new address_attributes

      # Final check: The billing address in memory may be the same as this address
      if not self.billing_address.blank?
        if self.shipping_address.street = self.billing_address.street and
          self.shipping_address.postal_code == self.billing_address.postal_code
          self.shipping_address = self.billing_address
        end
      end
    else
      self.shipping_address.update_attributes address_attributes
    end
    self.shipping_address
  rescue
    self.shipping_address = OrderAddress.new address_attributes
  end

  def set_product_cost
    self.product_cost = self.line_items_total
  end

  def line_items_total
    total = 0.0
    self.order_line_items.each do |line_item|
      total += line_item.unit_price
    end
    total
  end

  def address_required?
    codes = OrderStatusCode.find(:all)
    codes.each do |code|
      if self.order_status_code == code
        case code.name
        when 'CART' then return false
        else return true
        end
      end
    end
  end
end
