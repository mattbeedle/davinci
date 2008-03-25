require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  include MembershipSpecHelper

  before(:each) do
    @membership = Membership.new
  end

  it "should not be valid without a user group id" do
    @membership.attributes = valid_membership_attributes.except(:user_group_id)
    @membership.should_not be_valid
  end

  it "should not be valid with a non-numerical user group id" do
    @membership.attributes = valid_membership_attributes.with(:user_group_id => 'a')
    @membership.should_not be_valid
  end

  it "should not be valid without a user id" do
    @membership.attributes = valid_membership_attributes.except(:user_id)
    @membership.should_not be_valid
  end

  it "should not be valid with a non-numerical user id" do
    @membership.attributes = valid_membership_attributes.with(:user_id => 'a')
    @membership.should_not be_valid
  end

  it "should not be valid if user already a member" do
    @membership.attributes = valid_membership_attributes
    @membership.save!
    @membership = Membership.new valid_membership_attributes
    @membership.should_not be_valid
  end

  it "should be valid" do
    @membership.attributes = valid_membership_attributes
    @membership.should be_valid
  end

  describe 'when accepted and not banned' do
    before(:each) do
      @membership.accepted_at = Time.now
      @membership.banned_at = nil
    end

    it 'accepted? should return true' do
      @membership.accepted?.should == true
    end

    it 'approved? should return true' do
      @membership.approved?.should == true
    end

    it 'banned? should return false' do
      @membership.banned?.should == false
    end
  end

  describe 'when accepted and banned' do
    before(:each) do
      @membership.accepted_at = Time.now
      @membership.banned_at = Time.now
    end

    it 'accepted? should return true' do
      @membership.accepted?.should == true
    end

    it 'approved? should return false' do
      @membership.approved?.should == false
    end

    it 'banned? should return true' do
      @membership.banned?.should == true
    end
  end

  describe 'when not accepted' do
    before(:each) do
      @membership.accepted_at = nil
    end

    it 'accepted? should return false' do
      @membership.accepted?.should == false
    end

    it 'approved? should return false' do
      @membership.approved?.should == false
    end
  end

  describe 'create with notification' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      @inviter = mock_model(User, :id => 2)
      @membership.invited_by = @inviter
      @membership.user = @user
      User.stub!(:find_by_id)
      @notification = mock_model(Notification)
      Notification.stub!(:create_user_group_invitation).and_return(@notification)
      Membership.stub!(:create!).and_return(@membership)
    end

    def do_create
      Membership.create_with_notification!(:user_group_id => 1, :user_id => 1, :invited_by_id => 2)
    end

    it 'should create the membership' do
      Membership.should_receive(:create!).once.and_return(@membership)
      do_create
    end

    it 'should create the notification' do
      Notification.should_receive(:create_user_group_invitation).once.and_return(@notification)
      do_create
    end
  end
end
