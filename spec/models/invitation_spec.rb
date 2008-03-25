require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation , 'validations' do
  include InvitationSpecHelper

  before(:each) do
    @invitation = Invitation.new
  end

  it 'should not be valid without a sender id' do
    @invitation.attributes = valid_invitation_attributes.except(:sender_id)
    @invitation.should_not be_valid
    @invitation.sender_id = 1
    @invitation.should be_valid
  end

  it 'should not be valid with a non numerical sender id' do
    @invitation.attributes = valid_invitation_attributes.with(:sender_id => 'a')
    @invitation.should_not be_valid
    @invitation.sender_id = 1
    @invitation.should be_valid
  end

  it 'should not be valid without a receiver name' do
    @invitation.attributes = valid_invitation_attributes.except(:receiver_name)
    @invitation.should_not be_valid
    @invitation.receiver_name = 'test'
    @invitation.should be_valid
  end

  it 'should not be valid without a receiver email' do
    @invitation.attributes = valid_invitation_attributes.except(:receiver_email)
    @invitation.should_not be_valid
    @invitation.receiver_email = 'test@test.com'
    @invitation.should be_valid
  end

  it "should be valid" do
    @invitation.attributes = valid_invitation_attributes
    @invitation.should be_valid
  end
end
