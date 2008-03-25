require File.dirname(__FILE__) + '/../spec_helper'

describe Notification, 'validations' do
  include NotificationSpecHelper

  before(:each) do
    @notification = Notification.new
  end

  it 'should not be valid without sender id' do
    @notification.attributes = valid_notification_attributes.except(:sender_id)
    @notification.should_not be_valid
    @notification.sender_id = 1
    @notification.should be_valid
  end

  it 'should not be valid with a non numerical sender id' do
    @notification.attributes = valid_notification_attributes.with(:sender_id => 'a')
    @notification.should_not be_valid
    @notification.sender_id = 1
    @notification.should be_valid
  end

  it 'should not be valid without a receiver id' do
    @notification.attributes = valid_notification_attributes.except(:receiver_id)
    @notification.should_not be_valid
    @notification.receiver_id = 2
    @notification.should be_valid
  end

  it 'should not be valid with a non numerical receiver id' do
    @notification.attributes = valid_notification_attributes.with(:receiver_id => 'a')
    @notification.should_not be_valid
    @notification.receiver_id = 1
    @notification.should be_valid
  end

  it 'should not be valid without a notification type id' do
    @notification.attributes = valid_notification_attributes.except(:notification_type_id)
    @notification.should_not be_valid
    @notification.notification_type_id = 1
    @notification.should be_valid
  end

  it 'should not be valid with a non numerical notification type id' do
    @notification.attributes = valid_notification_attributes.with(:notification_type_id => 'a')
    @notification.should_not be_valid
    @notification.notification_type_id = 1
    @notification.should be_valid
  end

  it 'should not be valid without a notifyable id' do
    @notification.attributes = valid_notification_attributes.except(:notifyable_id)
    @notification.should_not be_valid
    @notification.notifyable_id = 1
    @notification.should be_valid
  end

  it 'should not be valid with a non-numerical notifyable id' do
    @notification.attributes = valid_notification_attributes.with(:notifyable_id => 'a')
    @notification.should_not be_valid
    @notification.notifyable_id = 1
    @notification.should be_valid
  end

  it "should be valid" do
    @notification.attributes = valid_notification_attributes
    @notification.should be_valid
  end
end

describe Notification, 'creating a new user group invitation notification' do
  include NotificationSpecHelper

  before(:each) do
    @notification = Notification.new
    @notification.attributes = valid_notification_attributes
    @notification_type = mock_model(NotificationType, :id => 1)
    @sender = mock_model(User, :id => 1)
    @receiver = mock_model(User, :id => 2)
    Notifier.stub!(:deliver_notification).and_return(nil)
    @notifyable = mock_model(UserGroup, :id => 1)
  end

  def do_create
    Notification.create_user_group_invitation(@sender, @receiver, @notifyable)
  end

  describe 'when notification type exists' do
    before(:each) do
      NotificationType.stub!(:find_by_name).and_return(@notification_type)
    end

    it 'should find the notification type' do
      NotificationType.should_receive(:find_by_name).once.with('UserGroupInvitation').and_return(@notification_type)
      do_create
    end

    it 'should create the notification' do
      Notification.should_receive(:create!).once.with(:sender => @sender, :receiver => @receiver,
                                                      :notification_type => @notification_type,
                                                      :notifyable_id => 1).and_return(@notification)
      do_create
    end

    it 'should email the notification' do
      Notifier.should_receive(:deliver_notification).once.and_return(nil)
      do_create
    end
  end

  describe 'when notification type does not exist' do
    before(:each) do
      NotificationType.stub!(:find_by_name).and_return(nil)
    end

    it 'should not find the notification type' do
      NotificationType.should_receive(:find_by_name).once.with('UserGroupInvitation').and_return(nil)
      do_create
    end

    it 'should not create the notification' do
      Notification.should_not_receive(:create!)
      do_create
    end

    it 'should not deliver the notification' do
      Notifier.should_not_receive(:deliver_notification)
      do_create
    end
  end
end
