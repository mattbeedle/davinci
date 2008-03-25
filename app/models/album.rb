class Album < ActiveRecord::Base
  attr_accessor :password

  attr_protected :salt, :crypted_password

  validates_presence_of :name, :user_id, :privacy_type
  validates_uniqueness_of :name, :scope => :user_id
  validates_numericality_of :user_id
  validates_presence_of :password, :if => :password_required?

  has_many :photos,
    :dependent => :destroy do
    def public
      find(:all,
           :conditions => ['photos.private = ?', false])
    end
  end
  belongs_to :user
  has_many :memberships_albums
  has_many :memberships,
    :through => :memberships_albums

  acts_as_taggable

  def featured_photo
    photo = self.photos.find(:first, :conditions => ['featured = ?', true])
    photo = self.photos.first if photo.blank?
    photo
  end

  def before_save
    self.permalink = self.name.gsub(/\s/, '-') if self.permalink.blank?
    encrypt_password
  end

  def to_param
    self.permalink
  end

  def authenticate(password)
    crypted_password == encrypt(password)
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def save_with_protection
    if self.user.has_role? 'power'
      self.remove_pro_attributes
    elsif self.user.has_role? 'standard'
      self.remove_power_attributes
      self.remove_pro_attributes
    end
    self.save_without_protection
  end

  alias_method_chain :save, :protection

  def save_with_protection!
    if self.user.has_role 'power'
      self.remove_pro_attributes
    elsif self.user.has_role? 'standard'
      self.remove_power_attributes
      self.remove_pro_attributes
    end
    self.save_without_protection!
  end

  alias_method_chain :save!, :protection

  def remove_power_attributes
  end

  def remove_pro_attributes
    self.default_photo_price = nil
  end

  protected

  def password_required?
    self.privacy_type == 'protected'
  end

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{permalink}--") if self.salt.blank?
    self.crypted_password = encrypt(password)
  end
end
