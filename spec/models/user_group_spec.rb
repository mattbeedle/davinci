require File.dirname(__FILE__) + '/../spec_helper'

describe UserGroup, 'validations' do
  include UserGroupSpecHelper

  before(:each) do
    @user_group = UserGroup.new
  end

  it "should not be valid without name" do
    @user_group.attributes = valid_user_group_attributes.except(:name)
    @user_group.should_not be_valid
  end

  it "should be valid" do
    @user_group.attributes = valid_user_group_attributes
    @user_group.should be_valid
  end
end

describe UserGroup, 'recent members' do
  before(:each) do
    @user = mock_model(User)
    @users = [@user]
    @users.stub!(:find).and_return(@users)
    @user_group = UserGroup.new
  end

  it 'should find all users belonging to the group' do
    @user_group.should_receive(:users).once.and_return(@users)
    @user_group.recent_members
  end

  it 'should limit the users and order by memberships.created_at'
end
