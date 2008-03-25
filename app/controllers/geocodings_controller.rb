class GeocodingsController < ApplicationController

  layout 'master'

  before_filter :login_required
  before_filter :user, :only => [:new, :create]
  before_filter :check_user, :only => [:new ,:create]

  def index
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photos = @album.photos.paginate(:per_page => 9,
                                     :page => params[:page] || 1)
    @photo = @album.photos.find_by_permalink(params[:photo]) if params[:photo]
    session[:geocode_photo] = @photos.first.id unless @photo
    session[:geocode_photo] = @photo.id if @photo
    @map = Mapstraction.new('map_div', :google)
    @map.set_map_type_init(MapType::HYBRID)
    @map.control_init(:large => true)
    if @user.geocode
      @map.center_zoom_init([@user.geocode.latitude, @user.geocode.longitude], 14)
    elsif
      @map.center_zoom_init([50.0000, -0.100000], 2)
    end
    @photos.each do |photo|
      if photo.lat and photo.lng
        @map.marker_init(create_photo_marker(photo))
      end
    end
    @map.event_init(@map, 'click',
                    "function(p) { new Ajax.Request('/users/#{@user.to_param}/albums/#{@album.to_param}/photos/#{@photos.first.to_param}/geocodings?loc='+p) }")

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @album =  @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id]) unless session[:geocode_photo]
    @photo = @album.photos.find(session[:geocode_photo]) if session[:geocode_photo]
    @photo.lat = params[:loc].split(',')[0]
    @photo.lng = params[:loc].split(',')[1]
    @photo.save_without_revision
    session[:geocode_photo] = nil

    respond_to do |format|
      format.html do
        flash[:notice] = 'Photo updated.'
        redirect_to user_album_geocodings_path(@user, @album)
      end
      format.js do
        @map = Variable.new('map')
        @markers = Array.new
        for photo in @album.photos
          if photo.lat and photo.lng
            @markers << create_photo_marker(photo)
          end
        end
        render :template => 'geocodings/create.rjs'
      end
    end
  end

  def update
    @user =  User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    session[:geocode_photo] = @photo.id
    respond_to do |format|
      format.html do
        flash[:notice] = "photo: '#{@photo.permalink}' selected."
        redirect_to user_album_geocodings_path(@user, @album)
      end
      format.js
    end
  end

  private

  def user
    @user ||= User.find_by_login(params[:user_id])
  end
  
  def check_user
    if @current_user.id != @user.id
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
  end
  
  def create_photo_marker(photo)
    Marker.new([photo.lat, photo.lng],
               :label => photo.original_filename,
               :info_bubble => '<img src="' + user_album_photo_path(:user_id => @user,
                                                                    :album_id => @album,
                                                                    :id => photo,
                                                                    :size => 'thumbnail.jpg"/>'))
  end
end
