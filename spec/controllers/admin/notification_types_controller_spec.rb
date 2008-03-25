require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::NotificationTypesController, 'GET /admin/notification_types/' do
  before(:each) do
    @notification_type = mock_model(NotificationType)
    @notification_types = [@notification_type]
    NotificationType.stub!(:find).and_return(@notification_types)
  end

  def do_get
    get :index
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find all notification types' do
      NotificationType.should_receive(:find).once.and_return(@notification_types)
      do_get
    end

    it 'should assign the notification types for the view' do
      do_get
      assigns[:notification_types].should == @notification_types
    end
  end

  describe 'when not logged in as admin' do
  end
end

describe Admin::NotificationTypesController, 'GET /admin/notification_types/1' do
  before(:each) do
    @notification_type = mock_model(NotificationType, :id => 1)
    NotificationType.stub!(:find_by_id).and_return(@notification_type)
  end

  def do_get
    get :show, :id => '1'
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the notification type' do
      NotificationType.should_receive(:find_by_id).once.with('1').and_return(@notification_type)
      do_get
    end

    it 'should assign the notification type for the view' do
      do_get
      assigns[:notification_type].should == @notification_type
    end
  end
end

describe Admin::NotificationTypesController, 'GET /admin/notification_types/new' do
  before(:each) do
    @notification_type = mock_model(NotificationType)
    NotificationType.stub!(:new).and_return(@notification_type)
  end

  def do_get
    get :new
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should instantiate a new notification type' do
      NotificationType.should_receive(:new).once.and_return(@notification_type)
      do_get
    end

    it 'should assign the notification type for the view' do
      do_get
      assigns[:notification_type] = @notification_type
    end
  end
end

describe Admin::NotificationTypesController, 'POST /admin/notification_types/' do
  include NotificationTypeSpecHelper

  before(:each) do
    @notification_type = mock_model(NotificationType, :save! => @notification_type)
    NotificationType.stub!(:new).and_return(@notification_type)
  end

  def do_post
    post :create, :notification_type => valid_notification_type_attributes
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should instantiate a new notification type with the posted attributes' do
      NotificationType.should_receive(:new).once.and_return(@notification_type)
      do_post
    end

    it 'should save the notification type' do
      @notification_type.should_receive(:save!).once.and_return(@notification_type)
      do_post
    end

    it 'should assign the notification type' do
      do_post
      assigns[:notification_type].should == @notification_type
    end

    it 'should redirect to notification types page' do
      do_post
      response.should redirect_to(admin_notification_types_path)
    end
  end
end

describe Admin::NotificationTypesController, 'GET /admin/notification_types/1/edit' do
  before(:each) do
    @notification_type = mock_model(NotificationType, :id => 1)
    NotificationType.stub!(:find_by_id).and_return(@notification_type)
  end

  def do_get
    get :edit, :id => '1'
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the notification type' do
      NotificationType.should_receive(:find_by_id).once.with('1').and_return(@notification_type)
      do_get
    end

    it 'should assign the found notification type' do
      do_get
      assigns[:notification_type].should == @notification_type
    end
  end

  describe 'when not administrator' do
  end
end

describe Admin::NotificationTypesController, 'PUT /admin/notification_types/1' do
  before(:each) do
    @notification_type = mock_model(NotificationType, :id => 1, :update_attributes => @notification_type)
    NotificationType.stub!(:find_by_id).and_return(@notification_type)
  end

  def do_put
    put :update, :id => '1', :notification_type => { :name => 'TestNotification', :description => 'askjhfjewhf' }
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the notification type' do
      NotificationType.should_receive(:find_by_id).once.with('1').and_return(@notification_type)
      do_put
    end

    it 'should update the notification type attributes' do
      @notification_type.should_receive(:update_attributes).once.and_return(@notification_type)
      do_put
    end

    it 'should create a flash success notice' do
      do_put
      flash[:notice].should == 'Notification type updated.'
    end

    it 'should redirect to notification types page' do
      do_put
      response.should redirect_to(admin_notification_types_path)
    end
  end

  describe 'when not administrator' do
  end
end

describe Admin::NotificationTypesController, 'DELETE /admin/notification_types/1' do
  before(:each) do
    @notification_type = mock_model(NotificationType, :id => 1, :destroy => @notification_type)
    NotificationType.stub!(:find_by_id).and_return(@notification_type)
  end

  def do_delete
    delete :destroy, :id => '1'
  end

  describe 'when logged in as administrator' do
    before(:each) do
      @user = mock_model(User, :id => 1, :has_role? => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the notification type' do
      NotificationType.should_receive(:find_by_id).once.with('1').and_return(@notification_type)
      do_delete
    end

    it 'should delete the notification type' do
      @notification_type.should_receive(:destroy).once.and_return(@notification_type)
      do_delete
    end

    it 'should create a flash success message' do
      do_delete
      flash[:notice].should == 'Notification type deleted.'
    end

    it 'should redirect to notification types page' do
      do_delete
      response.should redirect_to(admin_notification_types_path)
    end
  end

  describe 'when not administrator' do
  end
end
