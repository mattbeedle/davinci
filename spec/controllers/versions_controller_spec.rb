require File.dirname(__FILE__) + '/../spec_helper'

describe VersionsController, 'GET /users/matt/albums/test-album/photos/test-photo/versions when logged in as same owner' do
  before(:each) do
    @version = mock_model(Photo::Version)
    @versions = [@version]
    @photo = mock_model(Photo, :to_param => 'test-photo', :versions => @versions)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)

    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :index, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should assign the user for the view" do
    do_get
    assigns[:user].should == @user
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should find the specified album from within the albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should assign the album for the view" do
    do_get
    assigns[:album].should == @album
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_get
  end

  it "should assign the photo for the view" do
    do_get
    assigns[:photo].should == @photo
  end

  it "should find the versions belonging to the photo" do
    @photo.should_receive(:versions).once.and_return(@versions)
    do_get
  end

  it "should assign the versions for the view" do
    do_get
    assigns[:versions].should == @versions
  end
end

describe VersionsController,
  'GET /users/matt/albums/test-album/photos/test-photo/versions when logged in as different to owner' do

  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :index, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should create flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to view that page.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe VersionsController, 'GET /users/matt/albums/test-album/photos/test-photo/versions/1 when logged in as owner' do
  before(:each) do
    @version = mock_model(Photo::Version, :id => 1, :data => 'some binary data here', :original_filename => 'test-photo.jpg')
    @versions = [@version]
    @versions.stub!(:find).and_return(@version)
    @photo = mock_model(Photo, :to_param => 'test-photo', :versions => @versions)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)

    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :show, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 1
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should assign the user for the view" do
    do_get
    assigns[:user].should == @user
  end

  it "should find the albums belonging to the specified user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should assign the album for the view" do
    do_get
    assigns[:album].should == @album
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_get
  end

  it "should assign the photo for the view" do
    do_get
    assigns[:photo].should == @photo
  end

  it "should find the versions belonging to the found photo" do
    @photo.should_receive(:versions).once.and_return(@versions)
    do_get
  end

  it "should find the specified version from within the found versions" do
    @versions.should_receive(:find).once.with('1').and_return(@version)
    do_get
  end

  it "assign the version for the view" do
    do_get
    assigns[:version].should == @version
  end
end

describe VersionsController,
  'GET /users/matt/albums/test-album/photos/test-photo/versions/1 when logged in as different to owner' do

  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :show, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 1
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should create a flash error message" do
    do_get
    flash[:error] = 'You do not have permission to view that page.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe VersionsController, 'PUT /users/matt/albums/test-album/photos/test-photo/versions/1 when logged in as owner' do
  before(:each) do
    @version = mock_model(Photo::Version, :id => 1, :version => 2)
    @versions = [@version]
    @versions.stub!(:find).and_return(@version)
    @photo = mock_model(Photo, :to_param => 'test-photo', :versions => @versions, :revert_to! => true)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1
  end

  def do_put
    put :update, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 1
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should assign the user for the view" do
    do_put
    assigns[:user].should == @user
  end

  it "should find the albums belonging to the specified user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_put
  end

  it "should assign the album for the view" do
    do_put
    assigns[:album].should == @album
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_put
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_put
  end

  it "should assign the photo for the view" do
    do_put
    assigns[:photo].should == @photo
  end

  it "should find the versions belonging to the found photo" do
    @photo.should_receive(:versions).once.and_return(@versions)
    do_put
  end

  it "should find the specified version from within the found versions" do
    @versions.should_receive(:find).once.with('1').and_return(@version)
    do_put
  end

  it "assign the version for the view" do
    do_put
    assigns[:version].should == @version
  end
end

describe VersionsController, 'PUT /users/matt/albums/test-album/photos/test-photo/versions/1 when not logged in as owner' do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_put
    put :update, :user_id => 'matt', :album_id => 'test-photo', :photo_id => 'test-photo', :id => 1
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should create a flash error message" do
    do_put
    flash[:error].should == 'You do not have permission to view that page.'
  end

  it "should redirect" do
    do_put
    response.should be_redirect
  end
end
