class FriendshipsController < ApplicationController

  layout 'master'

  before_filter :login_required

  def index
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to view that page.'
      redirect_back_or_default('/')
      return false
    end
    @friends = @user.friends
    @pending_friends_by_me = @user.pending_friends_by_me.friends
    @pending_friends_for_me = @user.pending_friends_for_me.friends
    @family = @user.family
    @pending_family_by_me = @user.pending_friends_by_me.family
    @pending_family_for_me = @user.pending_friends_for_me.family
  end

  def new
    @user = User.find_by_login(params[:user_id])
    @users = User.find(:all)
    @users = @users.delete_if { |user| user.id == @current_user.id }
  end

  def create
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @friend = User.find_by_login(params[:friend])
    if @user.request_friendship_with(@friend, params[:friendship_type])
      flash[:notice] = 'Friendship requested.'
      redirect_to user_friendships_path(@user)
    else
      flash[:error] = 'An error occurred.'
      redirect_back_or_default('/')
    end
  end

  def edit
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to view that page.'
      redirect_back_or_default('/')
      return false
    end
    @friend = User.find_by_login(params[:id])
  end

  def update
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @friend = User.find_by_login(params[:id])
    if @user.accept_friendship_with(@friend)
      flash[:notice] = 'Friendship updated.'
      redirect_to user_friendships_path(@user)
    else
      flash[:error] = 'An error occurred.'
      redirect_back_or_default('/')
    end
  end

  def destroy
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @friend = User.find_by_login(params[:id])
    if @user.delete_friendship_with(@friend)
      flash[:notice] = 'Friendship updated.'
      redirect_to user_friendships_path(@user)
    else
      flash[:error] = 'An error occurred.'
      redirect_back_or_default('/')
    end
  end
end
