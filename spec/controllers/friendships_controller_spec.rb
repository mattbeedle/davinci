require File.dirname(__FILE__) + '/../spec_helper'

describe FriendshipsController, "GET /users/matt/friendships when logged in as same as url" do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    @users = [@user]
    @users.stub!(:family).and_return(@users)
    @users.stub!(:friends).and_return(@users)
    @user.stub!(:friends).and_return(@users)
    @user.stub!(:family).and_return(@users)
    @user.stub!(:pending_friends_by_me).and_return(@users)
    @user.stub!(:pending_friends_for_me).and_return(@users)
    User.stub!(:find_by_login).and_return(@user)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :index, :user_id => 'matt'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find the friends belonging to the found user" do
    @user.should_receive(:friends).once.and_return([@user])
    do_get
  end

  it "should assign the found friends for the view" do
    do_get
    assigns[:friends].should == @users
  end

  it 'should find the pending friends made by the user' do
    @user.should_receive(:pending_friends_by_me).twice.and_return(@users)
    do_get
  end

  it 'should assign the pending friends' do
    do_get
    assigns[:pending_friends_by_me].should == @users
  end

  it 'should find the pending friends made for the user' do
    @user.should_receive(:pending_friends_for_me).twice.and_return(@users)
    do_get
  end

  it 'should assign the pending friends' do
    do_get
    assigns[:pending_friends_for_me].should == @users
  end

  it 'should find the family belonging to the user' do
    @user.should_receive(:family).once.and_return(@users)
    do_get
  end

  it 'should assign the family' do
    do_get
    assigns[:family].should == @users
  end

  it 'should find the pending family made by the user' do
    @user.should_receive(:pending_friends_by_me).twice.and_return(@users)
    do_get
  end

  it 'should assign the pending family' do
    do_get
    assigns[:pending_family_by_me].should == @users
  end

  it 'should find the pending family made for the user' do
    @user.should_receive(:pending_friends_for_me).twice.and_return(@users)
    do_get
  end

  it 'should assign the pending family' do
    do_get
    assigns[:pending_family_for_me].should == @users
  end
end

describe FriendshipsController, 'GET /users/matt/friendships when logged in as different user' do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :index, :user_id => 'matt'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should create a flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to view that page.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe FriendshipsController, "GET /users/matt/friendships/new when logged in as same user as in url" do
  before(:each) do
    @current_user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 1

    @user = mock_model(User)
    @users = [@user]
    @users.stub!(:delete_if).and_return(@users)
    User.stub!(:find).and_return(@users)
  end

  def do_get
    get :new, :user_id => 'matt'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(1).and_return(@current_user)
    do_get
  end

  it "should find all the users in the system" do
    User.should_receive(:find).once.with(anything()).and_return(@users)
    do_get
  end

  it "should remove the current user from the found users" do
    @users.should_receive(:delete_if).once.and_return(@users)
    do_get
  end

  it "should assign the users for the view" do
    do_get
    assigns[:users].should == @users
  end
end

