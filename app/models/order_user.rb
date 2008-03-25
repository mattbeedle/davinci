require 'digest/sha1'
class OrderUser < ActiveRecord::Base
  attr_accessor :password

  has_one :shipping_address,
    :conditions => ['is_shipping = ?', true],
    :class_name => 'OrderAddress',
    :dependent => :destroy
  has_one :billing_address,
    :conditions => ['is_shipping = ?', false],
    :class_name => 'OrderAddress',
    :dependent => :destroy
  has_one :order_account,
    :dependent => :destroy
  has_many :orders
  belongs_to :user

  validates_presence_of :email
  validates_presence_of :password, :if => :password_required?
  validates_presence_of :password_confirmation, :if => :password_required?
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/
  validates_confirmation_of :email, :password
  validates_associated :shipping_address, :billing_address

  before_save :encrypt_password

  def build_shipping_address(shipping_address)
    if self.shipping_address.blank?
      self.shipping_address = OrderAddress.new(shipping_address.merge(:is_shipping => true))
      self.save!
    else
      self.shipping_address.update_attributes(shipping_address.merge(:is_shipping => true))
    end
  end

  def build_billing_address(billing_address)
    if self.billing_address.blank?
      self.billing_address = OrderAddress.new(billing_address.merge(:is_shipping => false))
      self.save!
    else
      self.billing_address.update_attributes(billing_address.merge(:is_shipping => false))
    end
  end

  def build_order_account(order_account_type)
    account = OrderAccount.new(order_account_type)
    account.order_address = self.billing_address
    self.order_account = account
    self.save
  end

  def self.from_user(user)
    OrderUser.new(:password_salt => user.salt,
                  :password_hash => user.crypted_password,
                  :email => user.email,
                  :user => user)
  end

  def self.authenticate(email, password)
    u = find(:first, :conditions => ['email = ?', email])
    u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(password)
    password_hash == encrypt(password)
  end

  def self.encrypt(salt, password)
     Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def encrypt(password)
    self.class.encrypt(password, self.password_salt)
  end

  private
  def encrypt_password
    return if password.blank?
    self.password_salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.password_hash = encrypt(password)
  end

  def password_required?
    password_hash.blank? || !password.blank?
  end
end
