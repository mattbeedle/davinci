require File.dirname(__FILE__) + '/../spec_helper'

describe GeocodingsController, 'GET /users/matt/albums/test-album/geocodings when logged in as same user as in url' do

  before(:each) do
    @geocode = mock_model(Geocode, :latitude => 51.406209, :longitude => -0.033144)
    @photo = mock_model(Photo, :geocode => nil, :lat => 51.2343234, :lng => -0.109734, :name => 'test-photo',
                        :description => 'This is a test photo', :original_filename => 'test-photo.jpg')
    @photo2 = mock_model(Photo, :geocode => nil, :lat => 51.2343234, :lng => -0.109734, :name => 'another-test-photo',
                         :description => 'This is another test photo', :original_filename => 'test-photo.jpg')
    @photos = [@photo, @photo2]
    @photos.stub!(:paginate).and_return(@photos)
    @album = mock_model(Album, :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :geocode => @geocode)
    User.stub!(:find_by_login).and_return(@user)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
    @map = mock_model(Mapstraction, :marker_init => nil, :center_zoom_init => nil, :control_init => nil,
                      :set_map_type_init => nil, :event_init => nil)
    Mapstraction.stub!(:new).and_return(@map)
  end

  def do_get
    get :index, :user_id => 'matt', :album_id => 'test-album'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(1).and_return(@user)
    do_get
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find the albums belonging to the specified user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get
  end

  it "should paginate the photos" do
    @photos.should_receive(:paginate).once.and_return(@photos)
    do_get
  end

  it "should assign the photos for the view" do
    do_get
    assigns[:photos].should == @photos
  end

  it "should create a new map object" do
    Mapstraction.should_receive(:new).once.and_return(@map)
    do_get
  end

  it "should set the map type to HYBRID" do
    @map.should_receive(:set_map_type_init).once
    do_get
  end

  it "should add controls to the map" do
    @map.should_receive(:control_init).once
    do_get
  end

  it "should add a marker to the map for each photo" do
    @map.should_receive(:marker_init).twice
    do_get
  end

  it "should assign the map for the view" do
    do_get
    assigns[:map].should == @map
  end
end

describe GeocodingsController,
  'POST /users/matt/albums/test-album/photos/test-photo/geocodings when logged in as same user as in url' do

  before(:each) do
    @photo = mock_model(Photo, :save_without_revision => @photo, :lat= => nil, :lng= => nil)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_post
    post :create, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo',
      :loc => '51.924553243,-0.131223423'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(1).and_return(@user)
    do_post
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_post
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_post
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_post
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_post
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_post
  end

  it "should update the photo with the lat,lng points" do
    @photo.should_receive(:lat=).once
    @photo.should_receive(:lng=).once
    do_post
  end

  it "should create a flash notice" do
    do_post
    flash[:notice].should == 'Photo updated.'
  end

  it "should redirect to index" do
    do_post
    response.should redirect_to(user_album_geocodings_path(@user, @album))
  end
end

describe GeocodingsController,
  'POST /users/matt/albums/test-album/photos/test-photo/geocodings when logged in as different user to the one in the url' do

  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_post
    post :create, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo',
      :loc => '51.924553243,-0.131223423'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(2).and_return(@current_user)
    do_post
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_post
  end

  it "should create a flash error message" do
    do_post
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_post
    response.should be_redirect
  end
end

describe GeocodingsController,
  'PUT /users/matt/albums/test-album/photos/test-photo/geocodings/test-photo when logged in as same user as in url' do

  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo', :id => 1, :permalink => 'test-photo')
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @abums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)

    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_put
    put :update, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 'test-photo'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should find the albums belonging to the specified user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the specified albums from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_put
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_put
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_put
  end

  it "should store the photo id in the session" do
    do_put
    session[:geocode_photo].should == @photo.id
  end

  it "should redirect to index" do
    do_put
    response.should redirect_to(user_album_geocodings_path(@user, @album))
  end
end
