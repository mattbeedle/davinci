require File.dirname(__FILE__) + '/../spec_helper'

describe InvitationsController, 'GET /users/matt/invitations/new' do
  before(:each) do
    @invitation = mock_model(Invitation)
    Invitation.stub!(:new).and_return(@invitation)
    @user = mock_model(User, :id => 1)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :new, :user_id => 'matt'
  end

  describe 'when logged in as same user as in the url' do
    before(:each) do
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_get
    end

    it 'should assign the found user' do
      do_get
      assigns[:user].should == @user
    end

    it 'should instantiate a new invitation' do
      Invitation.should_receive(:new).once.and_return(@invitation)
      do_get
    end

    it 'should assign the invitation' do
      do_get
      assigns[:invitation].should == @invitation
    end
  end

  describe 'when logged in as different user to the one in the url' do
    before(:each) do
      @current_user = mock_model(User, :id => 2)
      User.stub!(:find_by_id).and_return(@current_user)
      session[:user] = 2
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_get
    end

    it 'should create a flash error message' do
      do_get
      flash[:error].should == 'You do not have permission to view that page.'
    end

    it 'should redirect' do
      do_get
      response.should be_redirect
    end
  end
end

describe InvitationsController, 'POST /users/matt/invitations/' do
  include InvitationSpecHelper
  
  before(:each) do
    @invitation = mock_model(Invitation, :save! => @invitation)
    @invitations = [@invitation]
    @invitations.stub!(:new).and_return(@invitation)
    @user = mock_model(User, :id => 1, :invitations => @invitations)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, :user_id => 'matt', :invitation => valid_invitation_attributes
  end

  describe 'when logged in as same user as in the url' do
    before(:each) do
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      Notifier.stub!(:deliver_invitation).and_return(nil)
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_post
    end

    it 'should find the invitations belonging to the found user' do
      @user.should_receive(:invitations).once.and_return(@invitations)
      do_post
    end

    it 'should create a new invitation within the found invitations' do
      @invitations.should_receive(:new).once.and_return(@invitation)
      do_post
    end

    it 'should save the invitation' do
      @invitation.should_receive(:save!).once.and_return(@invitation)
      do_post
    end

    it 'should send the email' do
      Notifier.should_receive(:deliver_invitation).once.with(@invitation).and_return(nil)
      do_post
    end

    it 'should create a flash success message' do
      do_post
      flash[:notice].should == 'Invitation sent.'
    end

    it 'should redirect' do
      do_post
      response.should be_redirect
    end
  end

  describe 'when logged in as different user to the one in the url' do
    before(:each) do
      @current_user = mock_model(User, :id => 2)
      User.stub!(:find_by_id).and_return(@current_user)
      session[:user] = 2
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_post
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'You do not have permission to do that.'
    end

    it 'should redirect' do
      do_post
      response.should be_redirect
    end
  end
end
