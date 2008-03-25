class UserGroupsController < ApplicationController

  layout 'master'

  before_filter :login_required, :only => [:new, :create, :edit, :update, :invite, :add_album_form, :add_album]

  def index
    @user_groups = UserGroup.find(:all)
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @user_groups.to_xml, :status => :success, :location => user_groups_url
      end
    end
  end

  def show
    @user_group = UserGroup.find_by_permalink(params[:id])
    @photos = @user_group.photos(:limit => 10, :order => 'updated_at DESC')
    @albums = @user_group.albums(:limit => 10, :order => 'updated_at DESC')
    @tag_counts = @user_group.tag_counts
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @user_group.to_xml(:include => [:albums, :tag_counts]), :status => :success,
          :location => user_group_url(@user_group)
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => 'Not found.', :status => :error }
    end
  end

  def new
    @user_group = UserGroup.new
  end

  def create
    @user_group = UserGroup.new(params[:user_group])
    @user_group.save!
    @current_user.join_group(@user_group, 1)
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'User group created.'
        redirect_to user_group_path(@user_group)
      end
      wants.xml do
        render :xml => @user_group.to_xml, :status => :created,
          :location => user_group_url(@user_group)
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => :new
      end
      wants.xml { render :xml => @user_group.to_xml, :status => :error }
    end
  end

  def edit
    @user_group = UserGroup.find_by_permalink(params[:id])
    unless @user_group.is_admin?(@current_user)
      flash[:error] = 'Only group admins can edit the group.'
      redirect_to user_group_path(@user_group)
      return false
    end
  end

  def update
    @user_group = UserGroup.find_by_permalink(params[:id])
    unless @user_group.is_admin?(@current_user)
      respond_to do |wants|
        wants.html do
          flash[:error] = 'Only group admins can update the group.'
          redirect_to user_group_path(@user_group)
          return false
        end
        wants.xml do
          render :xml => 'Only group admins can update the group.', :status => :error
        end
      end
    end
    @user_group.update_attributes! params[:user_group]
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'User group updated.'
        redirect_to user_group_path(@user_group)
        return false
      end
      wants.xml do
        render :xml => @user_group.to_xml, :status => :updated,
          :location => user_group_url(@user_group)
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => :edit
      end
      wants.xml do
        render :xml => @user_group.to_xml, :status => :error
      end
    end
  end

  def destroy
  end

  def invite
    @user_group = UserGroup.find_by_permalink(params[:id])
    if @user_group.is_member?(@current_user)
      @relations = @current_user.relationships
      @relations.delete_if { |user| @user_group.is_member?(user) }
    else
      flash[:error] = 'You are not a member of this group.'
      redirect_to user_group_path(@user_group)
    end
  end

  def add_album_form
    @user_group = UserGroup.find_by_permalink(params[:id])
    unless @user_group.is_member?(@current_user)
      flash[:error] = 'You must be a member of the group to view that page.'
      redirect_to user_group_path(@user_group)
      return false
    end
    @albums = @current_user.albums
  end

  def add_album
    @user_group = UserGroup.find_by_permalink(params[:id])
    unless @user_group.is_member?(@current_user)
      respond_to do |wants|
        wants.html do
          flash[:error] = 'You must be a member of the group to do that.'
          redirect_to user_group_path(@user_group)
          return false
        end
        wants.xml do
          render :xml => 'You must be a member of the group to do that.', :status => :error
        end
      end
    end
    @album = @current_user.albums.find_by_id(params[:album])
    @user_group.add_album(@album)
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Album added.'
        redirect_to user_group_path(@user_group)
      end
      wants.xml do
        render :xml => @user_group.to_xml(:include => :albums), :status => :success,
          :location => user_group_url(@user_group)
      end
    end
  end
end
