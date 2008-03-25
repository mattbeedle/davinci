class PhotosController < ApplicationController

  layout 'master'

  before_filter :login_required, :except => [:index, :show, :download]

  def index
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @effects = {}
    # If logged in and owner of the album, display all photos
    if logged_in? and current_user == @user
      @photos = @album.photos
    else
      # Otherwise, only display the public (non-private) photos
      @photos = @album.photos.public
    end
    respond_to do |wants|
      wants.html
      wants.xml do 
        render :xml => @photos.to_xml, :status => :success,
          :location => user_album_photos_path(@user, @album)
      end
    end
  end

  def show
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:id])

    @photo.unsharp_mask!(:radius => @album.unsharp_radius,
                         :sigma => @album.unsharp_sigma,
                         :amount => @album.unsharp_amount,
                         :threshold => @album.unsharp_threshold) unless @album.unsharp_amount == 0

    @effects = {}
    @photo.resize!(:size_string => params[:size],
                   :crop => true) if params[:size]
    @photo.sepia!(params[:sepia][:threshold]) if params[:sepia] and params[:sepia][:threshold]
    @photo.solarize!(params[:solarize][:threshold]) if params[:solarize] and params[:solarize][:threshold]
    @photo.posterize!(params[:posterize][:levels]) if params[:posterize] and params[:posterize][:levels]
    @photo.despeckle! if params[:despeckle]
    @photo.enhance! if params[:enhance]
    if params[:quantize] and params[:quantize][:colors] and params[:quantize][:colorspace]
      @photo.quantize!(params[:quantize][:colors], params[:quantize][:colorspace])
    end
    if params[:charcoal] and params[:charcoal][:sigma] and params[:charcoal][:radius]
      @photo.charcoal!(params[:charcoal][:sigma], params[:charcoal][:radius])
    end
    if params[:modulate] and (params[:modulate][:brightness] or params[:modulate][:saturation] or params[:modulate][:hue])
      @photo.modulate!(params[:modulate][:brightness] || 1.0,
                       params[:modulate][:saturation] || 1.0,
                       params[:modulate][:hue] || 1.0)
    end
    @photo.oil_paint!(params[:oil_paint][:radius]) if params[:oil_paint] and params[:oil_paint][:radius]
    @photo.negate!(params[:negate]) if params[:negate]
    respond_to do |format|
      format.html
      format.png { render_flex_image(@photo) }
      format.jpg { render_flex_image(@photo) }
      format.xml do 
        render :xml => @photo.to_xml, :status => :success, 
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  end

  def new
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @album = @user.albums.find_by_permalink(params[:album_id])
    unless @current_user.active?
      flash[:error] = 'Your account appears to have expired.'
      redirect_to user_album_path(@user, @album)
      return false
    end
    @photo = Photo.new
  end

  def create
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    unless @user.active?
      flash[:error] = 'Your account appears to have expired.'
      redirect_to user_album_path(@user, params[:album_id])
      return false
    end
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.build(:data => params[:photo][:data],
                                 :original_filename => params[:photo][:data].original_filename,
                                 :content_type => params[:photo][:data].content_type,
                                 :description => params[:photo][:description])
    @photo.save!
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Photo uploaded successfully.'
        redirect_to user_album_path(@user, @album)
      end
      wants.xml do
        render :xml => @photo.to_xml, :status => :created, 
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => :new
      end
      wants.xml do
        render :xml => @photo.to_xml, :status => :error,
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  end

  def edit
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    if @current_user.id != @user.id
      if (!@album.friends_edit or !@user.is_my_friend?(@current_user)) and
        (!@album.family_edit or !@user.is_my_family?(@current_user))
        flash[:error] = 'You do not have permission to do that.'
        redirect_back_or_default('/')
        return false
      end
    end
    @photo = @album.photos.find_by_permalink(params[:id])

    @height = params[:height] || nil
    @width = params[:width] || nil
    @size = params[:size] || nil
    @effects = {}
    if params[:sepia] and params[:sepia][:threshold]
      @effects[:sepia] = { :threshold => params[:sepia][:threshold] }
    end
    if params[:solarize] and params[:solarize][:threshold]
      @effects[:solarize] = { :threshold => params[:solarize][:threshold] }
    end
    if params[:quantize] and params[:quantize][:colors] and params[:quantize][:colorspace]
      @effects[:quantize] = { :colors => params[:quantize][:colors], :colorspace => params[:quantize][:colorspace] }
    end
    if params[:posterize] and params[:posterize][:levels]
      @effects[:posterize] = { :levels => params[:posterize][:levels] }
    end
    if params[:charcoal] and params[:charcoal][:radius] and params[:charcoal][:sigma]
      @effects[:charcoal] = { :radius => params[:charcoal][:radius], :sigma => params[:charcoal][:sigma] }
    end
    if params[:despeckle]
      @effects[:despeckle] = true
    end
    if params[:enhance]
      @effects[:enhance] = true
    end
    if params[:modulate] and (params[:modulate][:brightness] or params[:modulate][:saturation] or params[:modulate][:hue])
      @effects[:modulate] = { :brightness => params[:modulate][:brightness] || 1.0,
        :saturation => params[:modulate][:saturation] || 1.0,
        :hue => params[:modulate][:hue] || 1.0 }
    end
    if params[:oil_paint] and params[:oil_paint][:radius]
      @effects[:oil_paint] = { :radius => params[:oil_paint][:radius] }
    end
    if params[:negate]
      @effects[:negate] = true;
    end
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page['preview'].replace_html :partial => 'photo', :locals => { :effects => @effects, 
            :height => @height, :width => @width, :size => @size || 'original' }
        end
      end
    end
  end

  def update
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    if @current_user.id != @user.id
      if (!@user.is_my_friend?(@current_user) or !@album.friends_edit) and
        (!@user.is_my_family?(@current_user) or !@album.family_edit)
        flash[:error] = 'You do not have permission to do that.'
        redirect_back_or_default('/')
        return false
      end
    end
    @photo = @album.photos.find_by_permalink(params[:id])
    changed_data = false

    if !@user.is_my_friend?(@current_user) and !@user.is_my_family?(@current_user)
    unless params[:size].blank?
      @photo.resize! :size_string => params[:size], :crop => params[:crop] || true
      changed_data = true
    end

    unless params[:sepia].blank? or params[:sepia][:threshold].blank?
      @photo.sepia! params[:sepia][:threshold]
      changed_data = true
    end

    unless params[:solarize].blank? or params[:solarize][:threshold].blank?
      @photo.solarize! params[:solarize][:threshold]
      changed_data = true
    end

    unless  params[:quantize].blank? or params[:quantize][:colors].blank? or params[:quantize][:colorspace].blank?
      @photo.quantize! params[:quantize][:colors], params[:quantize][:colorspace]
      changed_data = true
    end

    unless params[:posterize].blank? or params[:posterize][:levels].blank?
      @photo.posterize! params[:posterize][:levels]
      changed_data = true
    end

    unless params[:charcoal].blank? or params[:charcoal][:radius].blank? or params[:charcoal][:sigma].blank?
      @photo.charcoal! params[:charcoal][:radius], params[:charcoal][:sigma]
      changed_data = true
    end

    unless params[:despeckle].blank?
      @photo.despeckle!
      changed_data = true
    end

    unless params[:enhance].blank?
      @photo.enhance!
      changed_data = true
    end

    if params[:modulate] and (!params[:modulate][:brightness].blank? or 
                              !params[:modulate][:saturation].blank? or !params[:modulate][:hue].blank?)
      @photo.modulate! params[:modulate][:brightness], params[:modulate][:saturation], params[:modulate][:hue]
      changed_data = true
    end

    if not params[:oil_paint].blank? and not params[:oil_paint][:radius].blank?
      @photo.oil_paint! params[:oil_paint][:radius]
      changed_data = true
    end

    if not params[:negate].blank?
      @photo.negate!
      changed_data = true
    end

    unless params[:featured].blank?
      @album.photos.each do |photo|
        photo.update_attribute :featured, false
      end
      @photo.featured = true
    end
    end

    @photo.tag_list = params[:tags] unless params[:tags].blank?

    @photo.attributes = params[:photo] unless params[:photo].blank?

    # If data hasn't changed, we don't want to version the photo
    if changed_data
      @photo.save!
    else
      @photo.save_without_revision!
    end

    respond_to do |format|
      format.html do 
        flash[:notice] = 'Photo updated!'
        redirect_to user_album_photo_path(@user, @album, @photo)
      end
      format.xml do
        render :xml => @photo.to_xml, :status => :updated, 
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Update failed.'
        redirect_to edit_user_album_photo_path(@user, @album, @photo)
      end
      wants.xml do
        render :xml => @photo.to_xml, :status => :error, 
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  end

  def destroy
    @user = User.find_by_login(params[:user_id])
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:id])

    @photo.destroy
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Photo deleted.'
        redirect_to user_album_photos_path(@user, @album)
      end
      wants.xml do
        render :xml => @photo.to_xml, :status => :deleted,
          :location => user_album_photo_path(@user, @album, @photo)
      end
    end
  end

  def move_form
    @user = User.find_by_login(params[:user_id])
    if @user.id == @current_user.id
      @albums = @user.albums
    else
      flash[:error] = 'You do not have permission to view that page.'
      redirect_to user_album_photo_path(params[:user_id], params[:album_id], params[:id])
    end
  end

  def move
    @user = User.find_by_login(params[:user_id])
    if @user.id == @current_user.id
      @photo = @user.albums.find_by_permalink(params[:album_id]).photos.find_by_permalink(params[:id])
      @target_album = Album.find(params[:target_album][:id])
      @photo.album = @target_album
      @photo.featured = false
      @photo.save_without_revision!
      respond_to do |wants|
        wants.html do
          flash[:notice] = 'Album moved.'
          redirect_to user_album_photo_path(@user, @target_album, @photo)
        end
        wants.xml do
          render :xml => @photo.to_xml, :status => :moved,
            :location => user_album_photo_path(@user, @album, @photo)
        end
      end
    else
      respond_to do |wants|
        wants.html do
          flash[:error] = 'You do not have permission to do that.'
          redirect_to user_album_photo_path(@user, params[:album_id], params[:id])
          return false
        end
        wants.xml { render :xml => 'You do not have permission to do that.', :status => :error }
      end
    end
  end

  def download
    @photo = User.find_by_login(params[:user_id]).albums.find_by_permalink(
      params[:album_id]).photos.find_by_permalink(params[:id])
    @photo.to_jpg!(100)
    send_data(@photo.data,
              :content_type => 'image/jpeg',
              :filename => @photo.original_filename)
  end
end
