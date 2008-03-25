require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationsController do
  describe 'GET /users/matt/notifications/1' do
    def do_get
      get :show, :user_id => 'matt', :id => '1'
    end

    describe 'when logged in' do
      before(:each) do
        @notification = mock_model(Notification)
        @notifications = [@notification]
        @notifications.stub!(:find_by_id).and_return(@notification)
        @user = mock_model(User, :id => 1, :to_param => 'matt', :notifications => @notifications)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
      end

      it "should find the notifications belonging to the current user" do
        @user.should_receive(:notifications).once.and_return(@notifications)
        do_get
      end

      it "should find the specified notification from within the found notifications" do
        @notifications.should_receive(:find_by_id).once.with('1').and_return(@notification)
        do_get
      end

      it "should assign the found notification" do
        do_get
        assigns[:notification].should == @notification
      end
    end
  end
end

describe NotificationsController, 'GET /user/matt/notifications' do
  before(:each) do
    @notification = mock_model(Notification, :mark_as_read => @notification)
    @notifications = [@notification]
    @notifications.stub!(:latest).and_return(@notifications)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :received_notifications => @notifications)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :index, :user_id => 'matt'
  end

  it 'should find the notifications received by the current user' do
    @user.should_receive(:received_notifications).once.and_return(@notifications)
    do_get
  end

  it 'should find all the latest notifications from within the received notifications' do
    @notifications.should_receive(:latest).once.and_return(@notifications)
    do_get
  end

  it 'should mark all the notifications as read' do
    @notification.should_receive(:mark_as_read).once.and_return(@notification)
    do_get
  end

  it 'should assign the found notifications' do
    do_get
    assigns[:received_notifications].should == @notifications
  end
end
