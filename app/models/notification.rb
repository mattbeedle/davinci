class Notification < ActiveRecord::Base
  belongs_to :sender,
    :class_name => 'User'
  belongs_to :receiver,
    :class_name => 'User'
  belongs_to :notification_type

  validates_presence_of :sender_id, :receiver_id, :notification_type_id, :notifyable_id
  validates_numericality_of :sender_id, :receiver_id, :notification_type_id, :notifyable_id

  def self.create_user_group_invitation(sender, receiver, notifyable)
    notification_type = NotificationType.find_by_name('UserGroupInvitation')
    notification = Notification.create!(:sender => sender,
                                        :receiver => receiver,
                                        :notification_type => notification_type,
                                        :notifyable_id => notifyable.id) unless notification_type.blank?
    Notifier.deliver_notification(notification) unless notification.blank?
    notification
  end

  def mark_as_read
    self.update_attribute :read_at, Time.now
  end

  def body
    body = self.notification_type.description
    body = body.gsub(/SENDER/, self.sender.login)
    body = body.gsub(/RECEIVER/, self.receiver.login)
    case self.notification_type.notifyable_type
    when 'Membership'
      membership = Membership.find_by_id(self.notifyable_id)
      body = body.gsub(/USER_GROUP/, membership.user_group.name)
    end
  end
end
