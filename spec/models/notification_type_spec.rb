require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationType do
  include NotificationTypeSpecHelper

  before(:each) do
    @notification_type = NotificationType.new
  end

  it 'should not be valid without name' do
    @notification_type.attributes = valid_notification_type_attributes.except(:name)
    @notification_type.should_not be_valid
    @notification_type.name = 'Test'
    @notification_type.should be_valid
  end

  it 'should not be valid without a subject' do
    @notification_type.attributes = valid_notification_type_attributes.except(:subject)
    @notification_type.should_not be_valid
    @notification_type.subject = 'kjshfjkewhfkj'
    @notification_type.should be_valid
  end

  it 'should not be valid without description' do
    @notification_type.attributes = valid_notification_type_attributes.except(:description)
    @notification_type.should_not be_valid
    @notification_type.description = 'test description'
    @notification_type.should be_valid
  end

  it 'should not be valid without a notifyable type' do
    @notification_type.attributes = valid_notification_type_attributes.except(:notifyable_type)
    @notification_type.should_not be_valid
    @notification_type.notifyable_type = 'UserGroupInvitation'
    @notification_type.should be_valid
  end

  it "should be valid" do
    @notification_type.attributes = valid_notification_type_attributes
    @notification_type.should be_valid
  end
end
