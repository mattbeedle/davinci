require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  serialize :homepage_content_preferences

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password, :start_trial
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_protected :salt, :crypted_password

  acts_as_geocodable
  has_many_friends
  acts_as_authorized_user

  has_many :albums,
    :dependent => :destroy do
      def featured
        find(:all, :conditions => ['featured = ?', true])
      end
    end
  has_many :memberships,
    :dependent => :destroy
  has_many :user_groups,
    :through => :memberships
  has_many :comments,
    :dependent => :destroy
  has_many :invitations,
    :foreign_key => 'sender_id'
  belongs_to :invited_by,
    :class_name => 'User',
    :foreign_key => 'invited_by_id',
    :dependent => :nullify
  has_many :notifications,
    :dependent => :nullify
  has_many :received_notifications,
    :class_name => 'Notification',
    :foreign_key => 'receiver_id',
    :dependent => :nullify do
      def unread
        find(:all, :conditions => 'read_at IS NULL')
      end
      def read
        find(:all, :conditions => 'read_at IS NOT NULL')
      end
      def latest(options = {})
        find(:all,
             :order => 'created_at ASC',
             :limit => options[:limit] || 10)
      end
    end
  has_many :sent_notifications,
    :class_name => 'Notification',
    :foreign_key => 'sender_id',
    :dependent => :nullify do
      def unread
        find(:all, :conditions => 'read_at IS NULL')
      end
      def read
        find(:all, :conditions => 'read_at IS NOT NULL')
      end
      def latest(options = {})
        find(:all,
          :order => 'created_at ASC',
          :limit => options[:limit] || 10)
      end
    end
  has_many :order_addresses,
    :dependent => :destroy do
    def shipping
      find(:all,
           :conditions => ['is_shipping = ?', true])
    end
    def billing
      find(:all,
           :conditions => ['is_billing = ?', false])
    end
  end
  has_many :order_accounts,
    :dependent => :destroy
  has_many :orders,
    :dependent => :destroy do
    def active(options = {})
      find(:all,
           :include => :order_status_code,
           :conditions => "order_status_codes.name IN ('ON HOLD - AWAITING PAYMENT', 'ON HOLD - PAYMENT FAILED', 'ORDERED - PAID - TO SHIP')",
           :order => options[:order] || 'orders.created_at ASC',
           :limit => options[:limit] || nil)
    end
    def completed(options = {})
      find(:all,
           :include => :order_status_code,
           :conditions => "order_status_codes.name IN ('ORDERED - PAID - SHIPPED')",
           :order => options[:order] || 'orders.created_at ASC',
           :limit => options[:limit] || nil)
    end
  end

  def order_addresses
    billing_addresses = OrderAddress.find(:all,
                                          :include => [:billing_address_orders => :user],
                                          :conditions => ['users.id = ?', self.id],
                                          :order => 'order_addresses.created_at ASC')
    shipping_addresses = OrderAddress.find(:all,
                                           :include => [:shipping_address_orders => :user],
                                           :conditions => ['users.id = ?', self.id],
                                           :order => 'order_addresses.created_at ASC')
    shipping_addresses.each do |shipping_address|
      billing_addresses << shipping_address unless billing_addresses.include? shipping_address
    end
    shipping_addresses
  end

  def display_news?
    self.homepage_content_preferences[:news] == 'display'
  rescue
    true
  end

  def display_welcome?
    self.homepage_content_preferences[:welcome] == 'display'
  rescue
    true
  end

  def display_bio?
    self.homepage_content_preferences[:bio] == 'display'
  rescue
    true
  end

  def display_featured_albums?
    self.homepage_content_preferences[:featured_albums] == 'display'
  rescue
    false
  end

  def display_relationships?
    self.homepage_content_preferences[:relationships] == 'display'
  rescue
    false
  end

  def display_groups?
    self.homepage_content_preferences[:groups] == 'display'
  rescue
    false
  end

  def display_tags?
    self.homepage_content_preferences[:tags] == 'display'
  rescue
    false
  end

  def display_albums?
    self.homepage_content_preferences[:albums] == 'display'
  rescue
    true
  end

  # Return the photo select as the profile photo, or nil
  def photo
    Photo.find_by_id(self.profile_photo_id)
  end

  def album_tags
    Tag.find(:all,
             :select => 'tags.id, tags.name, COUNT(*) AS count',
             :joins => 'INNER JOIN taggings ON taggings.tag_id = tags.id ' +
             'INNER JOIN albums ON albums.id = taggings.taggable_id ' +
             'INNER JOIN users ON users.id = albums.user_id',
             :conditions => ['taggings.taggable_type = ? AND users.id = ?', 'Album', self.id],
             :group => 'tags.id, tags.name')
  end

  def photo_tags
    Tag.find(:all,
             :select => 'tags.id, tags.name, COUNT(*) AS count',
             :joins => 'INNER JOIN taggings ON taggings.tag_id = tags.id ' +
             'INNER JOIN photos ON photos.id = taggings.taggable_id ' +
             'INNER JOIN albums ON albums.id = photos.album_id ' +
             'INNER JOIN users ON users.id = albums.user_id',
             :conditions => ['taggings.taggable_type = ? AND users.id = ?', 'Photo', self.id],
             :group => 'tags.id, tags.name')
  end

  def tags
    self.album_tags + self.photo_tags
  end

  # before save method which sets the trial_started_at to the current time
  def start_trial
    self.trial_started_at = Time.now if self.new_record?
  end

  # Was the trial started longer ago than the trial length
  def trial_over?
    unless self.trial_started_at.blank?
      return Time.now - APP_CONFIG['trial_length'].days > self.trial_started_at
    else
      return false
    end
  end

  # Days remaining until the trial expires, if it is already expired, 0 is returned
  def trial_days_remaining
    days_elapsed = (Time.now.to_i - self.trial_started_at.to_i) / 60 / 60 / 24
    remaining = APP_CONFIG['trial_length'] - days_elapsed
    remaining = 0 if remaining < 0
    remaining
  end

  # Days remaining until the paid membership expires
  def paid_days_remaining
    days_elapsed = (Time.now.to_i - self.trial_started_at.to_i) / 60 / 60 / 24
    remaining = 365 - days_elapsed
    remaining = 0 if remaining < 0
    remaining
  end

  # Has the user paid within the last 365 days?
  def paid?
    unless self.last_paid_at.blank?
      return Time.now - 365.days < self.last_paid_at
    else
      return false
    end
  end

  # Is the users account not expired, don't know why the hell I called this function active?
  def active?
    !self.trial_over? or self.paid?
  end

  # Has the users account expired
  def expired?
    !self.active?
  end

  def to_param
    self.login
  end

  def notifications
    self.received_notifications + self.sent_notifications
  end

  # Sends an invitation to the email address specified.
  def send_invitation(email)
    chars = ["A".."Z","a".."z","0".."9"].collect { |r| r.to_a }.join
    code = (1..8).collect { chars[rand(chars.size)] }.pack("C*")
    invitation = Invitation.create!(:sender => self,
                                    :code => code,
                                    :receiver_email => email)
    if Notifier.deliver_invitation(invitation)
      self.update_attribute :sent_invitations, self.sent_invitations + 1
    end unless invitation.blank?
  end

  def is_my_friend?(user)
    friendship = Friendship.find(:first,
                                 :conditions => ['(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?) AND friendship_type = ?',
                                   self.id, user.id, user.id, self.id, 'friend'])
    friendship.blank? ? false : true
  end

  def is_my_family?(user)
    friendship = Friendship.find(:first,
                                 :conditions => ['user_id = ? AND friend_id = ? AND friendship_type = ?',
                                   self.id, user.id, 'family'])
    friendship.blank? ? false : true
  end

  # For protected user groups a user must request memberhip.  Accepted at is then populated when
  # an admin accepts the user
  def request_membership_of(user_group)
    Membership.create!(:user => self,
                       :admin => false,
                       :user_group => user_group)
  end

  # Used to accept a user to a protected group
  def accept_member_to(user_group, user)
    if user_group.is_admin? self
      membership = Membership.find_by_user_group_id_and_user_id(user_group.id, user.id)
      unless membership.blank?
        membership.accepted_at = Time.now
        membership.accepted_by = self
        membership.save!
        return true
      end
    end
    false
  end

  def ban_member_from(user_group, user)
    if user_group.is_admin? self
      membership = Membership.find_by_user_group_id_and_user_id(user_group.id, user.id)
      unless membership.blank?
        membership.banned_at = Time.now
        membership.banned_by = self
        membership.save!
        return true
      end
    end
    false
  end

  # Joins a group, bypassing the invite and accept mechanizms. Used for public groups
  def join_group(user_group, admin=0)
    Membership.create!(:user => self,
                       :user_group => user_group,
                       :admin => admin,
                       :accepted_at => Time.now) unless user_group.is_member?(self)
  end

  # Invite user to join a group
  def invite_to_group(user_group, user)
    if user_group.is_member?(self) and not user_group.is_member?(user)
      membership = Membership.create_with_notification!(:user => user,
                                                        :user_group => user_group,
                                                        :admin => false,
                                                        :invited_by => self,
                                                        :invited_at => Time.now)
      return true unless membership.blank?
    end
    return false
  end
  
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end 
end
