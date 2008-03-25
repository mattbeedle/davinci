require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::MembershipsController, 'GET /admin/user_groups/test-group/memberships' do
  before(:each) do
    @membership = mock_model(Membership)
    @memberships = [@memberships]
    @user = mock_model(User)
    @users = [@user]
    @user_group = mock_model(UserGroup, :to_param => 'test-group', :memberships => @memberships,
                             :members_awaiting_approval => @users, :non_admins => @users)
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :index, :user_group_id => 'test-group'
  end

  describe 'when logged in as group administrator' do
    before(:each) do
      @user_group.stub!(:is_admin?).and_return(true)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_get
    end

    it 'should assign the user group' do
      do_get
      assigns[:user_group].should == @user_group
    end

    it 'should check if the logged in user is a group admin' do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(true)
      do_get
    end

    it 'should find all the group users awaiting approval' do
      @user_group.should_receive(:members_awaiting_approval).once.and_return(@users)
      do_get
    end

    it 'should assign the awaiting users' do
      do_get
      assigns[:members_awaiting_approval].should == @users
    end

    it 'should find all the group users' do
      @user_group.should_receive(:non_admins).once.and_return(@users)
      do_get
    end

    it 'should assign the users' do
      do_get
      assigns[:approved_members].should == @users
    end
  end

  describe 'when logged in but not group administrator' do
    before(:each) do
      @user_group.stub!(:is_admin?).and_return(false)
    end

    it 'should find the group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_get
    end

    it 'should assign the group' do
      do_get
      assigns[:user_group].should == @user_group
    end

    it 'should check if the logged in user is an admin' do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(false)
      do_get
    end

    it 'should create a flash error message' do
      do_get
      flash[:error].should == 'You must be a group administrator to view that page.'
    end

    it 'should redirect to the user group page' do
      do_get
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end

describe Admin::MembershipsController, 'POST /admin/user_groups/test-group/memberships' do
  before(:each) do
    @user = mock_model(User, :id => 1, :accept_member_to => true, :ban_member_from => true)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
    @membership = mock_model(Membership)
    @memberships = [@membership]
    @memberships.stub!(:find_by_user_id_and_user_group_id).and_return(@membership)
    @user_group = mock_model(UserGroup, :to_param => 'test-group')
    UserGroup.stub!(:find_by_permalink).and_return(@user_group)
    User.stub!(:find).and_return(@user)
  end

  def do_post
    post :create, :user_group_id => 'test-group', :approval_users => { '1' => 'yes', '2' => 'no', '3' => 'yes' },
      :ban_users => { '4' => '1', '7' => '1' }
  end

  describe 'when logged in as group admin' do
    before(:each) do
      @user_group.stub!(:is_admin?).and_return(true)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it 'should assign the user group' do
      do_post
      assigns[:user_group].should == @user_group
    end

    it 'should check if the user is a group admin' do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(true)
      do_post
    end

    it 'should find all the users' do
      User.should_receive(:find).exactly(5).times.and_return(@user)
      do_post
    end

    it 'should accept all the users who need to be approved' do
      @user.should_receive(:accept_member_to).twice.with(@user_group, @user).and_return(true)
      do_post
    end

    it 'should ban all the users who are NOT to be approved and those to be banned' do
      @user.should_receive(:ban_member_from).exactly(3).times.with(@user_group, @user).and_return(true)
      do_post
    end

    it 'should create a flash success message' do
      do_post
      flash[:notice].should == 'Group users updated.'
    end

    it 'should redirect to membership admin page' do
      do_post
      response.should redirect_to(admin_user_group_memberships_path(@user_group))
    end
  end

  describe 'when logged in but not group admin' do
    before(:each) do
      @user_group.stub!(:is_admin?).and_return(false)
    end

    it 'should find the user group' do
      UserGroup.should_receive(:find_by_permalink).once.with('test-group').and_return(@user_group)
      do_post
    end

    it 'should assign the user group' do
      do_post
      assigns[:user_group].should == @user_group
    end

    it 'should check to see if the logged in user is a group admin' do
      @user_group.should_receive(:is_admin?).once.with(@user).and_return(false)
      do_post
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'You must be a group admin to do that.'
    end

    it 'should redirect to user group page' do
      do_post
      response.should redirect_to(user_group_path(@user_group))
    end
  end
end
