class Admin::MembershipsController < ApplicationController

  layout 'master'

  before_filter :login_required

  def index
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])
    if @user_group.is_admin?(@current_user)
      @members_awaiting_approval = @user_group.members_awaiting_approval
      @approved_members = @user_group.non_admins
    else
      flash[:error] = 'You must be a group administrator to view that page.'
      redirect_to user_group_path(@user_group)
    end
  end

  def show
  end

  def create
    @user_group = UserGroup.find_by_permalink(params[:user_group_id])
    if @user_group.is_admin?(@current_user)

      params[:approval_users].each do |approval|
        @current_user.accept_member_to(@user_group, User.find(approval[0])) if approval[1] == 'yes'
        @current_user.ban_member_from(@user_group, User.find(approval[0])) if approval[1] == 'no'
      end unless params[:approval_users].blank?

      params[:ban_users].each do |ban|
        @current_user.ban_member_from(@user_group, User.find(ban[0]))
      end unless params[:ban_users].blank?

      flash[:notice] = 'Group users updated.'
      redirect_to admin_user_group_memberships_path(@user_group)
    else
      flash[:error] = 'You must be a group admin to do that.'
      redirect_to user_group_path(@user_group)
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
