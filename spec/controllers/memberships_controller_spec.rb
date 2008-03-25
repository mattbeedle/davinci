require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipsController, 'GET /user_groups/test-group/memberships' do
  before(:each) do
    @membership = mock_model(Membership)
    @memberships = [@membership]
    @memberships.stub!(:paginate).and_return(@memberships)
    @user_group = mock_model(UserGroup, :approved_members => @memberships)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_get
    get :index, :user_group_id => 'test-group'
  end

  it "should find the specified user group" do
    UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
    do_get
  end

  it "should assign the user group" do
    do_get
    assigns[:user_group].should == @user_group
  end

  it "should find the memberships belonging to the found user group" do
    @user_group.should_receive(:approved_members).once.and_return(@memberships)
    do_get
  end

  it "should paginate the memberships" do
    @memberships.should_receive(:paginate).once.and_return(@memberships)
    do_get
  end

  it "should assign the memberships for the view" do
    do_get
    assigns[:memberships].should == @memberships
  end
end

describe MembershipsController, 'GET /user_groups/test-group/memberships/new' do
  before(:each) do
    @user_group = mock_model(UserGroup, :to_param => 'test-group')
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
    @membership = mock_model(Membership)
    Membership.stub!(:new).and_return(@membership)
  end

  def do_get
    get :new, :user_group_id => 'test-group'
  end

  describe 'when logged in as group admin' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_admin?).and_return(true)
      @users = [@user]
      @users.stub!(:delete_if).and_return(@users)
      User.stub!(:find).and_return(@users)
    end

    it "should find the group" do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_get
    end

    it "should assign the group for the view" do
      do_get
      assigns[:user_group].should == @user_group
    end

    it "check to see if the current user is an admin" do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(true)
      do_get
    end

    it "should instantiate a new membership object" do
      Membership.should_receive(:new).and_return(:membership)
      do_get
    end

    it "should assign the membership for the view" do
      do_get
      assigns[:membership].should == @membership
    end

    it "should find all the users" do
      User.should_receive(:find).once.and_return(@users)
      do_get
    end

    it "should assign the found users" do
      do_get
      assigns[:users].should == @users
    end
  end
end

describe MembershipsController, 'POST /user_groups/test-group/memberships' do
  include MembershipSpecHelper

  before(:each) do
    @membership = mock_model(Membership, :save! => @membership)
    @memberships = [@membership]
    @memberships.stub!(:new).and_return(@membership)
    @user_group = mock_model(UserGroup, :to_param => 'test-group', :memberships => @memberships)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_post
    post :create, :user_group_id => 'test-group', :membership => { :user_id => 1, :user_group_id => 2 }
  end

  describe 'when user group is public' do
    before(:each) do
      @user_group.stub!(:group_type).and_return('public')
      @user = mock_model(User, :id => 1, :join_group => @membership)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it "should find the user group" do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it "should assign the user group" do
      do_post
      assigns[:user_group].should == @user_group
    end

    it "should check that the user group is public" do
      @user_group.should_receive(:group_type).and_return('public')
      do_post
    end

    it "should create the membership" do
      @user.should_receive(:join_group).once.with(@user_group).and_return(@membership)
      do_post
    end

    it "should create a flash success message" do
      do_post
      flash[:notice].should == 'Group joined.'
    end

    it "should redirect to user group show page" do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when user group is protected' do
    before(:each) do
      @user_group.stub!(:group_type).and_return('protected')
      @user = mock_model(User, :id => 1, :request_membership_of => @membership)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it "should find the user group" do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it "should assign the user group" do
      do_post
      assigns[:user_group].should == @user_group
    end

    it "should request membership with the user group" do
      @user.should_receive(:request_membership_of).once.with(@user_group).and_return(@membership)
      do_post
    end

    it "should create a flash message" do
      do_post
      flash[:notice].should == 'Membership requested.'
    end

    it "should redirect to group show page" do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when user group is private' do
    before(:each) do
      @user_group.stub!(:group_type).and_return('private')
      @user = mock_model(User, :id => 1, :invite_to_group => @membership)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @invited_user = mock_model(User, :id => 2, :to_param => 'sam')
      User.stub!(:find_by_login).and_return(@invited_user)
    end

    def do_post
      post :create, :user_group_id => 'test-group', :user_id => 'sam'
    end

    it "should find the group" do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it "should assign the group" do
      do_post
      assigns[:user_group].should == @user_group
    end

    it "should check to see if the group is private"

    it "should find the invited user" do
      User.should_receive(:find_by_login).once.with('sam').and_return(@invited_user)
      do_post
    end

    it "should invite the user to the group" do
      @user.should_receive(:invite_to_group).once.with(@user_group, @invited_user).and_return(@membership)
      do_post
    end

    it "should create a flash message" do
      do_post
      flash[:notice].should == 'Invitation sent.'
    end

    it "should redirect to user group show page" do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when group is private and no user id is specified' do
    before(:each) do
      @user_group.stub!(:group_type).and_return('private')
      @user = mock_model(User, :id => 1, :invite_to_group => @membership)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @invited_user = mock_model(User, :id => 2, :to_param => 'sam')
      User.stub!(:find_by_login).and_return(@invited_user)
    end

    def do_post
      post :create, :user_group_id => 'test-group'
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'No user to invite specified.'
    end

    it 'should redirect to user group path' do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when group is private and invited user is not found' do
    before(:each) do
      @user_group.stub!(:group_type).and_return('private')
      @user = mock_model(User, :id => 1, :invite_to_group => @membership)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      User.stub!(:find_by_login).and_return(nil)
    end

    def do_post
      post :create, :user_group_id => 'test-group', :user_id => 'sam'
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'User not found.'
    end

    it 'should redirect to group page' do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when user group not found' do
    before(:each) do
      @user = mock_model(User, :id => 1, :invite_to_group => @membership)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      UserGroup.stub!(:find_by_permalink).and_return(nil)
    end

    def do_post
      post :create, :user_group_id => 'test-group', :user_id => 'sam'
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'User group not found.'
    end

    it 'should redirect to homepage' do
      do_post
      response.should redirect_to(home_logged_in_path)
    end
  end
end

describe MembershipsController, 'DELETE /user_groups/test-group/memberships/1' do
  before(:each) do
    @membership = mock_model(Membership, :id => 1, :user_id => 1, :user_group_id => 2, :destroy => @membership)
    @memberships = [@membership]
    @memberships.stub!(:find_by_id).and_return(@membership)
    @user_group = mock_model(UserGroup, :memberships => @memberships, :to_param => 'test-group')
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_delete
    delete :destroy, :user_group_id => 'test-group', :id => '1'
  end

  describe 'when logged in as same user as membership' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_delete
    end

    it 'should find the memberships belonging to the group' do
      @user_group.should_receive(:memberships).once.and_return(@memberships)
      do_delete
    end

    it 'should find the specified membership from within the found memberships' do
      @memberships.should_receive(:find_by_id).once.with('1').and_return(@membership)
      do_delete
    end

    it 'should delete the membership' do
      @membership.should_receive(:destroy).once.and_return(@membership)
      do_delete
    end

    it 'should create a flash success message' do
      do_delete
      flash[:notice].should == 'Membership deleted.'
    end

    it 'should redirect to the user group page' do
      do_delete
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when logged in but as different user to membership' do
    before(:each) do
      @user = mock_model(User, :id => 2)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 2
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_delete
    end

    it 'should find the memberships belonging to the group' do
      @user_group.should_receive(:memberships).once.and_return(@memberships)
      do_delete
    end

    it 'should find the membership' do
      @memberships.should_receive(:find_by_id).once.with('1').and_return(@membership)
      do_delete
    end

    it 'should check to see if the user is the same as the one specified by the membership' do
      @membership.should_receive(:id).and_return(1)
      @user.should_receive(:id).twice.and_return(2)
      do_delete
    end

    it 'should create a flash error message' do
      do_delete
      flash[:error].should == 'You cannot delete that membership.'
    end

    it 'should redirect to the user group page' do
      do_delete
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end

describe MembershipsController, 'POST /user_groups/test-group/memberships/invite' do
  before(:each) do
    @user_group = mock_model(UserGroup, :to_param => 'test-group')
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_post
    post :invite, :user_group_id => 'test-group', :users => { '1' => '1', '3' => '1', '4' => '1', '8' => '0' }
  end

  describe 'when logged in as group member' do
    before(:each) do
      @user = mock_model(User, :id => 1, :invite_to_group => true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      User.stub!(:find).and_return(@user)
      @membership = mock_model(Membership)
      @memberships = [@memberships]
      @user_group.stub!(:is_member?).and_return(true)
      @user_group.stub!(:memberships).and_return(@memberships)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it 'should assign the user group' do
      do_post
      assigns[:user_group].should == @user_group
    end

    it 'should check to see if the logged in user is a member' do
      @user_group.should_receive(:is_member?).once.with(@user).and_return(true)
      do_post
    end

    it "should cycle through the supplied user id's and find each user" do
      User.should_receive(:find).exactly(3).times.and_return(@user)
      do_post
    end

    it 'should invite each user to the user group' do
      @user.should_receive(:invite_to_group).exactly(3).times.with(@user_group, @user).and_return(true)
      do_post
    end

    it 'should create a flash success notice' do
      do_post
      flash[:notice].should == 'Users invited.'
    end

    it 'should redirect to user group page' do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when logged in but not group member' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_member?).and_return(false)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it 'should assign the user group' do
      do_post
      assigns[:user_group].should == @user_group
    end

    it 'should check to see if the logged in user is a member' do
      @user_group.should_receive(:is_member?).and_return(false)
      do_post
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'You need to be a member of the group to do that.'
    end

    it 'should redirect to user group path' do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end
