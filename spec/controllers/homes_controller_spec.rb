require File.dirname(__FILE__) + '/../spec_helper'

describe HomesController, "GET /" do
  def do_get
    get :index
  end

  it "should be success" do
    do_get
    response.should be_success
  end

  it "should not be redirect" do
    do_get
    response.should_not be_redirect
  end
end

describe HomesController, "GET / when logged in" do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :index
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe HomesController, "GET /index_logged_in when not logged in" do
  def do_get
    get :index_logged_in
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe HomesController, "GET /index_logged_in when logged in" do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :index_logged_in
  end

  it "should be success" do
    do_get
    response.should be_success
  end

  it "should not redirect" do
    do_get
    response.should_not be_redirect
  end
end

describe HomesController do
  describe 'PUT update_stylesheet' do
    def do_put
      put :update_stylesheet, :stylesheet => 'black'
    end

    it "should update the session" do
      do_put
      session[:stylesheet].should == 'black'
    end

    describe 'when logged in' do
      before(:each) do
        @user = mock_model(User, :id => 1)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
      end

      it 'should redirect to user show page' do
        do_put
        response.should redirect_to(user_path(@user))
      end
    end

    describe 'when not logged in' do
      it "should redirect to index page" do
        do_put
        response.should redirect_to(index_path)
      end
    end
  end
end
