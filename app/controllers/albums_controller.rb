class AlbumsController < ApplicationController

  layout 'master'

  before_filter :login_required, :except => [:index, :show, :login_form, :login]

  def index
    @user = User.find_by_login(params[:user_id])
    if is_owner?(@user)
      @albums = @user.albums.paginate(:per_page => 20,
                                      :page => params[:page] || 1)
    else
      @albums = @user.albums.paginate(:per_page => 20,
                                      :page => params[:page] || 1,
                                      :conditions => ['privacy_type != ?', 'private'])
    end
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @albums.to_xml, :status => "200 OK", :location => user_albums_path(@user) }
    end
  end

  def show
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:id])
    if @album.privacy_type == 'protected'
      if (session[:albums].blank? or session[:albums][@album.id].blank?) and not is_owner?(@user)
        session[:return_to] = request.request_uri
        redirect_to login_form_user_album_path(@user, @album)
        return false
      end
    end
    if logged_in? and current_user == @user
      @photos = @album.photos.paginate(:per_page => 50,
                                       :page => params[:page] || 1,
                                       :order => "#{@album.sort_by} #{@album.sort_direction}")
    else
      @photos = @album.photos.public.paginate(:per_page => 50,
                                              :page => params[:page] || 1,
                                              :order => "#{@album.sort_by} #{@album.sort_direction}")
    end
    respond_to do |wants|
      wants.html do
        case @album.style
        when 'davinci' then render :template => 'albums/show'
        when 'traditional' then render :template => 'albums/traditional'
        when 'all thumbs' then render :template => 'albums/all_thumbs'
        when 'slideshow' then render :template => 'albums/slideshow'
        when 'journal' then render :template => 'albums/journal'
        when 'filmstrip' then render :template => 'albums/filmstrip'
        when 'critique' then render :template => 'albums/critique'
        else
          render :template => 'albums/show'
        end
      end
      wants.xml { render :xml => @album.to_xml, :status => "200 OK", :location => user_album_path(@user, @album) }
    end
  end

  def new
    @user = User.find_by_login(params[:user_id])
    if !is_owner?(@user)
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    unless @user.active?
      flash[:error] = 'Your account appears to have expired.'
      redirect_to user_path(@user)
      return false
    end
    @album = Album.new
  end

  def create
    @user = User.find_by_login(params[:user_id])
    if !is_owner?(@user)
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    unless @user.active?
      flash[:error] = 'Your account appears to have expired.'
      redirect_to user_path(@user)
      return false
    end
    @album = @user.albums.build(params[:album])
    @album.tag_list = params[:tags] if params[:tags]
    @album.save!
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Album created.'
        redirect_to new_user_album_photo_path(@user, @album)
      end

      wants.xml { render :xml => @album.to_xml, :status => :created, :location => user_album_path(@user, @album) }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => :new
      end

      wants.xml { render :xml => @album.to_xml }
    end
  end

  def edit
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:id])
    if !is_owner?(@user)
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @no_theme = true # We don't want a themed edit page
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @album.to_xml }
    end
  end

  def update
    @user = User.find_by_login(params[:user_id])
    if !is_owner?(@user)
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @album = @user.albums.find_by_permalink(params[:id])
    @album.tag_list = params[:tags] if params[:tags]
    @album.update_attributes! params[:album]
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Album updated.'
        redirect_to user_album_path(@user, @album)
      end

      wants.xml { render :xml => @album.to_xml, :status => :updated, :location => user_album_path(@user, @album) }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => :edit
      end
      wants.xml { render :xml => @album.to_xml, :status => :error, :location => user_album_path(@user, @album) }
    end
  end

  def destroy
    @user = User.find_by_login(params[:user_id])
    if !is_owner?(@user)
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
      return false
    end
    @album = @user.albums.find_by_permalink(params[:id])
    @album.destroy
    respond_to do |wants|
      wants.html { redirect_to user_albums_path(@user) }
      wants.xml { render :xml => 'Deleted', :status => :deleted }
    end
  end

  def login_form
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:id])
  end

  def login
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:id])
    if @album.authenticate(params[:album_password])
      flash[:notice] = 'Password correct.'
      session[:albums] = {} if session[:albums].blank?
      session[:albums][@album.id] = true
      redirect_to session[:return_to] || user_album_path(@user, @album)
    else
      flash[:error] = 'Password incorrect.'
      render :action => :login_form
    end
  end
end
