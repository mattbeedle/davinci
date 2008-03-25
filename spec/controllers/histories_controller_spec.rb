require File.dirname(__FILE__) + '/../spec_helper'

describe HistoriesController, 'GET /users/matt/history when logged in as matt' do
  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    Photo.stub!(:find).and_return(@photos)
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :show, :user_id => 'matt'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find all the photos belonging to the user" do
    Photo.should_receive(:find).once.and_return(@photos)
    do_get
  end

  it "should assign the photos for the view" do
    do_get
    assigns[:photos].should == @photos
  end
end

describe HistoriesController, 'GET /users/matt/history when logged in as different' do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :show, :user_id => 'matt'
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
