class VersionsController < ApplicationController

  layout 'master'

  before_filter :login_required, :only => [:index, :show, :update]

  def index
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to view that page.'
      redirect_back_or_default('/')
      return false
    end
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    @versions = @photo.versions
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @versions.to_xml, :status => :success,
          :location => user_album_photo_versions_url(@user, @album, @photo)
      end
    end
  end

  def show
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to view that page.'
      redirect_back_or_default('/')
      return false
    end
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    @version = @photo.versions.find(params[:id])
    respond_to do |format|
      format.jpg do
        send_data(@version.data,
                  :content_type => 'image/jpeg',
                  :filename => @version.original_filename,
                  :disposition => 'inline')
      end
      format.xml do
        render :xml => @version.to_xml, :status => :success,
          :location => user_album_photo_version_url(@user, @album, @photo, @version)
      end
    end
  end

  def update
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      respond_to do |wants|
        wants.html do
          flash[:error] = 'You do not have permission to view that page.'
          redirect_back_or_default('/')
          return false
        end
        wants.xml do
          render :xml => 'You do not have permission to view that page.', :status => :error,
            :location => user_album_photo_path(@user, @album, @photo)
        end
      end
    end
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    @version = @photo.versions.find(params[:id])
    @photo.revert_to!(@version.version)
    respond_to do |format|
      format.html do
        flash[:notice] = 'Photo reverted successfully.'
        redirect_to user_album_photo_path(@user, @album, @photo)
      end
      format.xml do
        render :xml => @photo.to_xml, :status => :success,
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  end
end
