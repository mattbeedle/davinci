require File.dirname(__FILE__) + '/../spec_helper'

describe UserGroupsController, 'GET /user_groups' do
  before(:each) do
    @user_group = mock_model(UserGroup)
    @user_groups = [@user_group]
    UserGroup.stub!(:find).and_return(@user_groups)
  end

  def do_get
    get :index
  end

  it "should find all the user groups" do
    UserGroup.should_receive(:find).once.and_return(@user_groups)
    do_get
  end

  it "should assign the found groups for the view" do
    do_get
    assigns[:user_groups].should == @user_groups
  end
end

describe UserGroupsController, 'GET /user_groups/test-group' do
  before(:each) do
    @tag = mock_model(Tag)
    @tags = [@tag]
    @photo = mock_model(Photo)
    @photos = [@photo]
    @album = mock_model(Album)
    @albums = [@album]
    @user_group = mock_model(UserGroup, :to_param => 'test-group', :photos => @photos, :albums => @albums,
                             :tag_counts => @tags)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_get
    get :show, :id => 'test-group'
  end

  it "should find the specified user group" do
    UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
    do_get
  end

  it 'should find a selection of photos belonging to the user group' do
    @user_group.should_receive(:photos).once.with(:limit => 10, :order => 'updated_at DESC').and_return(@photos)
    do_get
  end

  it 'should assign the found photos' do
    do_get
    assigns[:photos].should == @photos
  end

  it 'should find a selection of albums belonging to the user group' do
    @user_group.should_receive(:albums).once.with(:limit => 10, :order => 'updated_at DESC').and_return(@albums)
    do_get
  end

  it 'should assign the found albums' do
    do_get
    assigns[:albums].should == @albums
  end

  it 'should find the tag counts for the user group' do
    @user_group.should_receive(:tag_counts).once.and_return(@tags)
    do_get
  end

  it 'should assign the tag counts' do
    do_get
    assigns[:tag_counts].should == @tags
  end

  it "should assign the found group for the view" do
    do_get
    assigns[:user_group].should == @user_group
  end
end

describe UserGroupsController, 'GET /user_groups/new' do
  before(:each) do
    @user_group = mock_model(UserGroup)
    UserGroup.stub!(:new).and_return(@user_group)
  end

  def do_get
    get :new
  end

  describe 'when logged in' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it "should instantiate a new user group object" do
      UserGroup.should_receive(:new).once.and_return(@user_group)
      do_get
    end

    it "should assign the user group for the view" do
      do_get
      assigns[:user_group].should == @user_group
    end
  end

  describe 'when not logged in' do
    
    it "should NOT instantiate a new user group object" do
      UserGroup.should_not_receive(:new)
      do_get
    end
  end
end

describe UserGroupsController, 'POST /user_groups/' do
  include UserGroupSpecHelper

  before(:each) do
    @user_group = mock_model(UserGroup, :to_param => 'test-group', :save! => @user_group)
    UserGroup.stub!(:new).and_return(@user_group)
  end

  def do_post
    post :create, :user_group => valid_user_group_attributes
  end

  describe 'when logged in' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user.stub!(:join_group).and_return(@membership)
    end

    it "should instantiate and hydrate the user group" do
      UserGroup.should_receive(:new).once.and_return(@user_group)
      do_post
    end

    it "should save the user group" do
      @user_group.should_receive(:save!).once.and_return(@user_group)
      do_post
    end

    it "should add the logged in user to the group as an admin" do
      @user.should_receive(:join_group).once.with(@user_group, 1).and_return(@user)
      do_post
    end

    it "should create a flash success message" do
      do_post
      flash[:notice].should == 'User group created.'
    end

    it "should redirect to user group show" do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when not logged in' do
    
    it "should not create the user group" do
      UserGroup.should_not_receive(:create!)
      do_post
    end
  end
end

describe UserGroupsController, 'GET /user_groups/test-group/edit' do
  before(:each) do
    @user_group = mock_model(UserGroup, :id => 2, :to_param => 'test-group')
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_get
    get :edit, :id => 'test-group'
  end

  describe 'when logged in as admin' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_admin?).and_return(true)
    end

    it "should find the group" do
      UserGroup.should_receive(:find_by_permalink).once.and_return(@user_group)
      do_get
    end

    it "should assign the found group for the view" do
      do_get
      assigns[:user_group].should == @user_group
    end

    it "should check to see if the logged in user is a group admin" do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(true)
      do_get
    end
  end

  describe 'when logged in, but not admin' do
    before(:each) do
     @user = mock_model(User, :id => 1)
     User.stub!(:find_by_id).and_return(@user)
     session[:user] = 1
     @user_group.stub!(:is_admin?).and_return(false)
    end

    it "should find the group" do
      UserGroup.should_receive(:find_by_permalink).once.and_return(@user_group)
      do_get
    end

    it "should assign the group" do
      do_get
      assigns[:user_group].should == @user_group
    end

    it "should create a flash error message" do
      do_get
      flash[:error].should == 'Only group admins can edit the group.'
    end

    it "should redirect to group show page" do
      do_get
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end

describe UserGroupsController, 'PUT /user_groups/test-group' do
  include UserGroupSpecHelper

  before(:each) do
    @user_group = mock_model(UserGroup, :id => 2, :to_param => 'test-group', :update_attributes => @user_group)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_put
    put :update, :id => 'test-group', :user_group => valid_user_group_attributes
  end

  describe 'when logged in as admin' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_admin?).and_return(true)
    end

    it "should find the user group" do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_put
    end

    it "should assign the user group" do
      do_put
      assigns[:user_group].should == @user_group
    end

    it "should check to see if this user is an admin of the group" do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(true)
      do_put
    end

    it "should update the group" do
      @user_group.should_receive(:update_attributes).once.and_return(@user_group)
      do_put
    end

    it "should create a flash success message" do
      do_put
      flash[:notice].should == 'User group updated.'
    end

    it "should redirect to the group show page" do
      do_put
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when logged in, but not an admin' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_admin?).and_return(false)
    end

    it "should find the user group" do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_put
    end

    it "should assign the user group" do
      do_put
      assigns[:user_group].should == @user_group
    end

    it "should check to see if this user is an admin of the group" do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(false)
      do_put
    end

    it "should create a flash error message" do
      do_put
      flash[:error].should == 'Only group admins can update the group.'
    end

    it "should redirect to the group show page" do
      do_put
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end

describe UserGroupsController, 'GET /user_groups/test-group/invite' do
  before(:each) do
    @user_group = mock_model(UserGroup, :to_param => 'test-group')
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_get
    get :invite, :id => 'test-group'
  end

  describe 'when logged in and member of the group' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      @users = [@user]
      @users.stub!(:delete_if).and_return(@users)
      @user.stub!(:relationships).and_return(@users)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_member?).and_return(true)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_get
    end

    it 'should assign the user group' do
      do_get
      assigns[:user_group].should == @user_group
    end

    it 'should check if the logged in user is an member' do
      @user_group.should_receive(:is_member?).once.with(@user).and_return(true)
      do_get
    end

    it 'should find the friends belonging to the logged in user' do
      @user.should_receive(:relationships).once.and_return(@users)
      do_get
    end

    it 'should remove the friends who are already group members' do
      @users.should_receive(:delete_if).once.and_return(@users)
      do_get
    end

    it 'should assign the found friends' do
      do_get
      assigns[:relations].should == @users
    end
  end

  describe 'when logged in and not member of the group' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
      @user_group.stub!(:is_member?).and_return(false)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_get
    end

    it 'should assign the user group' do
      do_get
      assigns[:user_group].should == @user_group
    end

    it 'should check if the logged in user is an member' do
      @user_group.should_receive(:is_member?).once.with(@user).and_return(false)
      do_get
    end

    it 'should create a flash error message' do
      do_get
      flash[:error].should == 'You are not a member of this group.'
    end

    it 'should redirect to user group page' do
      do_get
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end

describe UserGroupsController, 'GET /user_groups/test-group/add_album' do
  before(:each) do
    @user_group = mock_model(UserGroup, :to_param => 'test-group', :id => 2)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
    @user = mock_model(User, :id => 1)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :add_album_form, :id => 'test-group'
  end

  describe 'when logged in and member' do
    before(:each) do
      @user_group.stub!(:is_member?).and_return(true)
      @album = mock_model(Album)
      @albums = [@album]
      @user.stub!(:albums).and_return(@albums)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_get
    end

    it 'should assign the user group' do
      do_get
      assigns[:user_group].should == @user_group
    end

    it 'should find the albums belonging to the user' do
      @user.should_receive(:albums).once.and_return(@albums)
      do_get
    end

    it 'should assign the found albums' do
      do_get
      assigns[:albums].should == @albums
    end
  end

  describe 'when logged in but not member' do
    before(:each) do
      @user_group.stub!(:is_member?).and_return(false)
    end

    it 'should create a flash error message' do
      do_get
      flash[:error].should == 'You must be a member of the group to view that page.'
    end

    it 'should redirect to user group page' do
      do_get
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end

describe UserGroupsController, 'PUT /user_groups/test-group/add_album' do
  before(:each) do
    @album = mock_model(Album, :id => 1)
    @albums = [@album]
    @albums.stub!(:find_by_id).and_return(@album)
    @user = mock_model(User, :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
    @user_group = mock_model(UserGroup, :to_param => 'test-group', :add_album => @user_group)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
  end

  def do_put
    put :add_album, :id => 'test-group', :album => '1'
  end

  describe 'when logged in and member' do
    before(:each) do
      @user_group.stub!(:is_member?).and_return(true)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_put
    end

    it 'should find the albums belonging to the user' do
      @user.should_receive(:albums).once.and_return(@albums)
      do_put
    end

    it 'should find the album from within the albums' do
      @albums.should_receive(:find_by_id).once.with('1').and_return(@album)
      do_put
    end

    it 'should add the album to the user group' do
      @user_group.should_receive(:add_album).once.with(@album).and_return(@user_group)
      do_put
    end

    it 'should create a flash success message' do
      do_put
      flash[:notice].should == 'Album added.'
    end

    it 'should redirect to user group page' do
      do_put
      response.should redirect_to(user_group_path(@user_group))
    end
  end

  describe 'when logged in but not member' do
    before(:each) do
      @user_group.stub!(:is_member?).and_return(false)
    end

    it 'should create a flash error' do
      do_put
      flash[:error].should == 'You must be a member of the group to do that.'
    end

    it 'should redirect to user group page' do
      do_put
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end
