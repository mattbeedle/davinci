class MembershipsController < ApplicationController

  layout 'master'

  before_filter :login_required, :only => [:new, :create, :edit, :destroy, :invite]

  def index
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])
    @memberships = @user_group.approved_members.paginate(:per_page => 30,
                                                         :page => params[:page] || 1)
  end

  def show
  end

  def new
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])
    @user_group.is_admin?(@current_user)
    @membership = Membership.new
    @users = User.find(:all)
  end

  def create
    # Find the user group
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])

    # If the group is not found error and return to user group
    if @user_group.blank?
      flash[:error] = 'User group not found.'
      redirect_to home_logged_in_path
      return false
    end

    # Public group
    if @user_group.group_type == 'public'
      @current_user.join_group(@user_group)
      flash[:notice] = 'Group joined.'
      redirect_to user_group_path(@user_group)
      return false

    # Protected group
    elsif @user_group.group_type == 'protected'
      @current_user.request_membership_of(@user_group)
      flash[:notice] = 'Membership requested.'
      redirect_to user_group_path(@user_group)
      return false

    # Private group
    elsif @user_group.group_type == 'private'

      # No user id
      if params[:user_id].blank?
        flash[:error] = 'No user to invite specified.'
        redirect_to user_group_path(@user_group)
        return false
      end

      # User not found
      if (@user = User.find_by_login(params[:user_id])) == nil
        flash[:error] = 'User not found.'
        redirect_to user_group_path(@user_group)
        return false
      end
      
      @current_user.invite_to_group(@user_group, @user)
      flash[:notice] = 'Invitation sent.'
      redirect_to user_group_path(@user_group)
      return false
    end
  end

  def destroy
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])
    @membership = @user_group.memberships.find_by_id(params[:id])
    if @membership.id == @current_user.id
      @membership.destroy
      flash[:notice] = 'Membership deleted.'
      redirect_to user_group_path(@user_group)
      return false
    end
    flash[:error] = 'You cannot delete that membership.'
    redirect_to user_group_path(@user_group)
  end

  def invite
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])
    if @user_group.is_member?(@current_user)
      for id in params[:users]
        @current_user.invite_to_group(@user_group, User.find(id[0])) unless id[1].to_i == 0
      end
      flash[:notice] = 'Users invited.'
      redirect_to user_group_path(@user_group)
    else
      flash[:error] = 'You need to be a member of the group to do that.'
      redirect_to user_group_path(@user_group)
    end
  end
end
