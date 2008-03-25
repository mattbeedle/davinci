class UsersController < ApplicationController

  layout 'master'

  before_filter :user, :only => [:show, :edit, :update, :destroy, :my_groups]
  before_filter :login_required, :only => [:edit, :update, :destroy, :set_profile_photo, :my_groups] 

  def user
    @user = User.find_by_login(params[:id])
  end

  def show
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @user.to_xml(:include => :albums) }
    end
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session

    invitation = Invitation.find_by_code(params[:code]) unless params[:code].blank?
    @user = User.new(params[:user])
    if not params[:code].blank? and invitation.blank?
      flash[:error] = 'The code you entered does not match any in our database.'
      render :action => 'new'
      return false
    end
    @user.invited_by = invitation.sender unless invitation.blank?
    @user.activated_at = Time.now # TODO remove this, and get activation emails working
    @user.save!

    # Set user role for specified account
    case params[:account_type]
    when 'standard'
      @user.has_role 'standard'
    when 'power'
      @user.has_role 'power'
    when 'pro'
      @user.has_role 'pro'
    else
      @user.has_role 'standard'
    end

    self.current_user = @user
    respond_to do |wants|
      wants.html do
        redirect_back_or_default('/')
        flash[:notice] = "Thanks for signing up!"
      end

      wants.xml do
        headers['location'] = user_url(@user)
        render :xml => @user.to_xml, :status => "201 Created"
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html { render :action => 'new' }
      wants.xml { render :xml => @user.to_xml, :status => "400 Failed" }
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

  def edit
    respond_to do |wants|
      wants.html do
        if @user.blank?
          flash[:notice] = 'User not found'
          redirect_to user_path(current_user.to_param)
        elsif @user != @current_user
          flash[:notice] = 'You do not have permission to view that page.'
          redirect_to user_path(current_user.to_param)
        end
      end

      wants.xml do
        if @user.blank?
          render :xml => 'User not found'
        elsif @user != @current_user
          render :xml => 'You do not have permission to view that page.'
        else
          render :xml => @user.to_xml
        end
      end
    end
  end

  def update
    @user.update_attributes! params[:user]
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Profile updated'
        redirect_to user_path(@user)
      end

      wants.xml { render :xml => @user.to_xml, :status => :updated, :location => user_path(@user) }
    end
  rescue
    respond_to do |wants|
      wants.html do
        flash[:error] = 'Profile update unsuccessfull'
        render :action => :edit
      end

      wants.xml { render :xml => @user.to_xml, :status => :error }
    end
  end

  def destroy
    respond_to do |wants|
      wants.html do
        if @user.destroy
          flash[:notice] = 'User'
          redirect_to home_path
        end
      end

      wants.xml do
        if @user.destroy
          render :xml => @user.to_xml, :status => "200 destroyed"
        end
      end
    end
  end

  def set_profile_photo
    @updated = @user.update_attribute :profile_photo_id, params[:profile_photo_id]
    respond_to do |wants|
      wants.html do
        if @updated
          flash[:notice] = 'Profile photo set.'
          redirect_to user_path(@user)
        else
          flash[:notice] = 'Error setting profile photo.'
          redirect_to user_path(@user)
        end
      end

      wants.xml do
        if @updated
          headers['location'] = user_url(@user)
          render :xml => @user.to_xml, :status => "200 OK"
        else
          render :xml => 'Error setting profile photo.'
        end
      end
    end
  end

  def my_groups
    @groups = @current_user.user_groups
    respond_to do |wants|
      wants.html

      wants.xml do
        render :xml => @groups.to_xml
      end
    end
  end
end
