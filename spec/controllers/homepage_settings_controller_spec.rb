require File.dirname(__FILE__) + '/../spec_helper'

describe HomepageSettingsController, 'GET /homepage_settings/edit' do

  describe 'when logged in' do
    before(:each) do
      @user = mock_model(User, :id => 1, :to_param => 'matt')
      User.stub!(:find_by_login).and_return(@user)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    def do_get
      get :edit
    end

    it 'should be success' do
      do_get
      response.should be_success
    end

    it 'should render edit template' do
      do_get
      response.should render_template(:edit)
    end
  end

  describe 'when not logged in' do
    before(:each) do
      @user = mock_model(User, :id => 1, :to_param => 'matt')
      User.stub!(:find_by_login).and_return(@user)
    end

    def do_get
      get :edit
    end

    it 'should redirect' do
      do_get
      response.should be_redirect
    end
  end
end

describe HomepageSettingsController, 'POST /homepage_settings' do

  def do_post
    post :update, :preferences => { :news => true, :welcome => true, 
      :bio => false, :featured_albums => true, :relationships => true,
      :groups => true, :tags => true, :albums => true }
  end

  describe 'when logged in' do
    before(:each) do
      @user = mock_model(User, :id => 1, :homepage_content_preferences= => @user, :save => @user)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should update the current users homepage preferences' do
      @user.should_receive(:homepage_content_preferences=).once.and_return(@user)
      do_post
    end

    it 'should redirect' do
      do_post
      response.should be_redirect
    end
  end

  describe 'when not logged in' do
    it 'should redirect' do
      do_post
      response.should be_redirect
    end
  end
end
