class NotificationType < ActiveRecord::Base
  has_many :notifications,
    :dependent => :destroy

  validates_presence_of :name, :subject, :description, :notifyable_type

  def read?
    self.read
  end
end
