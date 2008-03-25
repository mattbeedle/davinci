class Membership < ActiveRecord::Base

  belongs_to :user_group
  belongs_to :user
  belongs_to :accepted_by,
    :class_name => 'User'
  belongs_to :invited_by,
    :class_name => 'User'
  belongs_to :banned_by,
    :class_name => 'User'
  has_many :memberships_albums
  has_many :albums,
    :through => :memberships_albums

  validates_presence_of :user_group_id, :user_id
  validates_numericality_of :user_group_id, :user_id
  validates_uniqueness_of :user_id, :scope => :user_group_id

  def accepted?
    unless self.accepted_at.blank?
      return true
    end
    false
  end

  def approved?
    if not self.accepted_at.blank? and self.banned_at.blank?
      return true
    end
    false
  end

  def banned?
    unless self.banned_at.blank?
      return true
    end
    false
  end

  def self.create_with_notification!(attributes = nil)
    membership = self.create!(attributes)
    sender = User.find_by_id(membership.invited_by.id)
    receiver = User.find_by_id(membership.user.id)
    Notification.create_user_group_invitation(sender, receiver, membership)
    membership
  end
end
