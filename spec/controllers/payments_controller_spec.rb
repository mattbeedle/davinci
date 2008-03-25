require File.dirname(__FILE__) + '/../spec_helper'

describe PaymentsController do
  describe 'POST /payments' do
    before(:each) do
      @user = mock_model(User, :id => 1, :to_param => 'matt', :last_paid_at= => @user, 
                         :membership_expires_on= => @user, :save => @user)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    def do_post
      post :create
    end

    it "should set the last paid at time to now" do
      @user.should_receive(:last_paid_at=).once.and_return(@user)
      do_post
    end

    it "should add one year to the membership expiry date" do
      @user.should_receive(:membership_expires_on=).once.with(Date.today+1.year).and_return(@user)
      do_post
    end

    it "should save the user" do
      @user.should_receive(:save).once.and_return(@user)
      do_post
    end

    it "should create a flash success message" do
      do_post
      flash[:notice].should == 'Thank you! You now have a whole extra year of membership...'
    end

    it "should redirect to home page" do
      do_post
      response.should redirect_to(home_path(@user))
    end
  end
end
