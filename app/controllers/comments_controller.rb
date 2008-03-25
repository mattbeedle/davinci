class CommentsController < ApplicationController

  layout 'master'

  before_filter :login_required, :only => [:destroy]

  def index
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    @comments = @photo.comments.paginate(:per_page => 20,
                                         :page => params[:page] || 1)
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @comments.to_xml, :status => :success, 
          :location => user_album_photo_comments_path(@user, @album, @photo)
      end
    end
  end

  def new
    @album = User.find_by_login(params[:user_id]).albums.find_by_permalink(params[:album_id])
    unless @album.commentable
      flash[:error] = 'Commenting is turned off for photos in this album.'
      redirect_to user_album_photo_path(params[:user_id], params[:album_id], params[:photo_id])
      return false
    end
    @comment = Comment.new
  end

  def create
    @album = User.find_by_login(params[:user_id]).albums.find_by_permalink(params[:album_id])
    unless @album.commentable
      flash[:error] = 'Commenting is turned off for photos in this album.'
      redirect_to user_album_photo_path(params[:user_id], params[:album_id], params[:photo_id])
      return false
    end
    @comment = @album.photos.find_by_permalink(
      params[:photo_id]).comments.build(params[:comment])
    @comment.user = current_user if logged_in?
    @comment.user_id = 0 unless logged_in?
    @comment.save!
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Comment added.'
        redirect_to user_album_photo_path(params[:user_id], params[:album_id], params[:photo_id])
      end
      wants.xml do
        render :xml => @comment.to_xml, :status => :created,
          :location => user_album_photo_comments_path(@user, @album, @photo)
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html { render :action => :new }
      wants.xml { render :xml => @comment.to_xml, :status => :error }
    end
  end

  def destroy
    @user = User.find_by_login(params[:user_id])
    if @user.id == @current_user.id
      @user.albums.find_by_permalink(params[:album_id]).photos.find_by_permalink(params[:photo_id]).comments.find(params[:id]).destroy
      respond_to do |wants|
        wants.html do
          flash[:notice] = 'Comment deleted.'
          redirect_to user_album_photo_path(params[:user_id], params[:album_id], params[:photo_id])
        end
        wants.xml { render :xml => @user.to_xml, :status => :deleted }
      end
    else
      respond_to do |wants|
        wants.html do
          flash[:error] = 'You do not have permission to do that.'
          redirect_back_or_default('/')
        end
        wants.xml { render :xml => 'You do not have permission to do that.', :status => :error }
      end
    end
  end
end
