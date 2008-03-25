require File.dirname(__FILE__) + '/../spec_helper'

describe OrderUsersController do

  describe "GET 'new'" do
    before :each do
      @user = mock_model(User)
      User.stub!(:new).and_return(@user)
    end

    def do_get
      get :new
    end

    it "should instantiate a new user" do
      User.should_receive(:new).once.and_return(@user)
      do_get
    end

    it "should assign the order user" do
      do_get
      assigns[:user].should == @user
    end
  end

  describe "POST 'create'" do
    include OrderUserSpecHelper

    before :each do
      @user = mock_model(User, :save! => @user, :has_role => @user)
      User.stub!(:new).and_return(@user)
      session[:return_to] = '/cart/billing'
    end

    def do_post
      post :create, :order_user => valid_order_user_post_attributes
    end

    describe 'when order user valid' do

      it "should create the order user" do
        User.should_receive(:new).once.and_return(@user)
        do_post
      end

      it "should set the user's role to equal 'order-user'" do
        @user.should_receive(:has_role).once.with('order-user').and_return(@user)
        do_post
      end

      it "should save the order user" do
        @user.should_receive(:save!).once.and_return(@user)
        do_post
      end

      it "should create flash success message" do
        do_post
        flash[:notice].should == 'You have registered.'
      end

      it "should redirect to specified location" do
        do_post
        response.should redirect_to(session[:return_to])
      end
    end
  end
end
