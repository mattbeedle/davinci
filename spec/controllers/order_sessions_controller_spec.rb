require File.dirname(__FILE__) + '/../spec_helper'

describe OrderSessionsController do

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'create'" do
    before :each do
      @order_user = mock_model(OrderUser, :id => 1)
    end

    def do_post
      post :create, :email => 'test@test.com', :password => 'password'
    end

    describe "when order user is found" do
      before :each do
        OrderUser.stub!(:authenticate).and_return(@order_user)
        session[:return_to] = '/cart/checkout'
      end

      it "should find the order user" do
        OrderUser.should_receive(:authenticate).once.with('test@test.com', 'password').and_return(@order_user)
        do_post
      end

      it "should add the order user id to the session" do
        do_post
        session[:order_user].should == 1
      end

      it "should redirect to the return url stored in the session" do
        do_post
        response.should redirect_to('/cart/checkout')
      end
    end

    describe "when order user is not found" do
      before :each do
        OrderUser.stub!(:authenticate).and_return(nil)
      end

      it "should create a flash error notice" do
        do_post
        flash[:error].should == 'Email or password invalid.'
      end

      it "should render the 'new' template" do
        do_post
        response.should render_template(:new)
      end
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      get 'destroy'
      response.should be_success
    end
  end
end
