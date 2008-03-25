require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumsController, "GET /users/matt/albums when logged in as same user as in url" do
  before(:each) do
    @album = mock_model(Album)
    @albums = [@album]
    @albums.stub!(:paginate).and_return(@albums)

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@matt)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :index, :user_id => 'matt'
  end

  it "should find all the albums belonging to matt" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should paginate the albums" do
    @albums.should_receive(:paginate).once.and_return(@albums)
    do_get
  end

  it "should assign the albums for the view" do
    do_get
    assigns[:albums].should == @albums
  end

  it "should be success" do
    do_get
    response.should be_success
  end

  it "should not be redirect" do
    do_get
    response.should_not be_redirect
  end
end

describe AlbumsController, 'GET /users/matt/albums/ when logged in as different user and all albums are private' do
  before(:each) do
    @albums = mock_model(Album, :privacy_type => 'private')
    @albums = [@album]
    @albums.stub!(:paginate).and_return(nil)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
  end

  def do_get
    get :index, :user_id => 'matt'
  end

  it "should not return any albums" do
    @albums.should_receive(:paginate).once.and_return(nil)
    do_get
  end
end

describe AlbumsController, 'GET /users/matt/albums/test-album' do
  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:public).and_return(@photos)
    @photos.stub!(:public).and_return(@photos)
    @album = mock_model(Album, :privacy_type => 'public', :photos => @photos, :sort_by => 'created_at',
                        :sort_direction => 'ASC')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'test-album', :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :show, :user_id => 'matt', :id => 'test-album'
  end

  describe 'when style is davinci' do
    before(:each) do
      @album.stub!(:style).and_return('davinci')
    end

    it 'should render the show template' do
      do_get
      response.should render_template('show')
    end
  end

  describe 'when style is traditional' do
    before(:each) do
      @album.stub!(:style).and_return('traditional')
    end

    it 'should render the traditional template' do
      do_get
      response.should render_template('traditional')
    end
  end

  describe "when style is 'all thumbs'" do
    before(:each) do
      @album.stub!(:style).and_return('all thumbs')
    end

    it "should render the 'all_thumbs' template" do
      do_get
      response.should render_template('all_thumbs')
    end
  end

  describe "when style is 'slideshow'" do
    before(:each) do
      @album.stub!(:style).and_return('slideshow')
    end

    it "should render the 'slideshow' template" do
      do_get
      response.should render_template('slideshow')
    end
  end

  describe "when style is 'journal'" do
    before(:each) do
      @album.stub!(:style).and_return('journal')
    end
    
    it "should render the 'journal' template" do
      do_get
      response.should render_template('journal')
    end
  end

  describe "when style is 'filmstrip'" do
    before(:each) do
      @album.stub!(:style).and_return('filmstrip')
    end

    it "should render the 'filmstrip' template" do
      do_get
      response.should render_template('filmstrip')
    end
  end

  describe "when style is 'critique'" do
    before(:each) do
      @album.stub!(:style).and_return('critique')
    end

    it "should render the 'critique' template" do
      do_get
      response.should render_template('critique')
    end
  end
end

describe AlbumsController, "GET /users/matt/albums/test-album when logged in as same user as in url" do
  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:public).and_return(@photos)
    @photos.stub!(:paginate).and_return(@photos)
    @album = mock_model(Album, :privacy_type => 'public', :photos => @photos, :sort_by => 'created_at',
                        :sort_direction => 'DESC', :style => 'davinci')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@matt)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :show, :user_id => 'matt', :id => 'test-album'
  end

  it "should find the user" do
    User.should_receive(:find_by_login).and_return(@user)
    do_get
  end

  it "should find the albums for the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should find the specified album from the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should assign the found album for the view" do
    do_get
    assigns[:album].should == @album
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

  it "should be success" do
    do_get
    response.should be_success
  end

  it "should not be redirect" do
    do_get
    response.should_not be_redirect
  end
end

describe AlbumsController, 'GET /users/matt/albums/test-album when logged in as different user and album is protected' do
  before(:each) do
    @album = mock_model(Album, :privacy_type => 'protected', :style => 'davinci')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :show, :user_id => 'matt', :id => 'test-album'
  end

  it "should redirect to album login path" do
    do_get
    response.should redirect_to(login_form_user_album_path(@user, @album))
  end
end

describe AlbumsController, "GET /users/matt/albums/new" do
  before(:each) do
    @album = mock_model(Album, :privacy_type => 'public')
    Album.stub!(:new).and_return(@album)

    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :new, :user_id => 'matt'
  end

  describe 'when logged in as same user as in url and account active' do
    before(:each) do
      @user.stub!(:active?).and_return(true)
    end

    it "should find the user" do
      User.should_receive(:find_by_login).and_return(@user)
      do_get
    end

    it "should instantiate a new album" do
      Album.should_receive(:new).once.and_return(@album)
      do_get
    end

    it "should assign the album for the view" do
      do_get
      assigns[:album].should == @album
    end

    it "should be success" do
      do_get
      response.should be_success
    end
  end

  describe 'when logged in as same user as in url but account expired' do
    before(:each) do
      @user.stub!(:active?).and_return(false)
    end

    it 'should find the user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_get
    end

    it 'should check if the user\'s account has expired' do
      @user.should_receive(:active?).once.and_return(false)
      do_get
    end

    it 'should create a flash error message' do
      do_get
      flash[:error].should == 'Your account appears to have expired.'
    end

    it 'should redirect to the logged in home page' do
      do_get
      response.should redirect_to(user_path(@user))
    end
  end
end

describe AlbumsController, "GET /users/matt/albums/new when logged in as different user to the one in url" do
  before(:each) do
    @album = mock_model(Album, :privacy_type => 'public')
    Album.stub!(:new).and_return(@album)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2

    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :new, :user_id => 'matt'
  end

  it "should set flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe AlbumsController, "POST /users/matt/albums" do
  include AlbumSpecHelper
  
  before(:each) do
    @tag_list = mock_model(TagList)
    @album = mock_model(Album, :save! => @album, :privacy_type => 'public', :tag_list => @tag_list, :tag_list= => @tag_list,
                        :featured= => @album)
    @albums = [@album]
    @albums.stub!(:build).and_return(@album)

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, :user_id => 'matt', :album => valid_album_attributes, :tags => 'test, test-photo, photo, matt'
  end

  describe 'when logged in as same user as in url and account active' do
    before(:each) do
      @user.stub!(:active?).and_return(true)
    end

    it "should find the user" do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_post
    end

    it "should find the albums for the user" do
      @user.should_receive(:albums).once.and_return(@albums)
      do_post
    end

    it "should build a new album within the found users albums" do
      @albums.should_receive(:build).once.with(anything()).and_return(@album)
      do_post
    end

    it "should replace the tag list with the supplied tags" do
      @album.should_receive(:tag_list=).once.with('test, test-photo, photo, matt').and_return(@tag_list)
      do_post
    end

    it "should save the new album" do
      @album.should_receive(:save!).once.and_return(@album)
      do_post
    end

    it 'should create a flash success message' do
      do_post
      flash[:notice].should == 'Album created.'
    end

    it "should redirect to the new photo page for this album" do
      do_post
      response.should redirect_to(new_user_album_photo_path(@user, @album))
    end
  end

  describe 'when logged in as same user as in url but account expired' do
    before(:each) do
      @user.stub!(:active?).and_return(false)
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_post
    end

    it 'should check if the user\'s account has expired' do
      @user.should_receive(:active?).once.and_return(false)
      do_post
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'Your account appears to have expired.'
    end

    it 'should redirect to the home logged in page' do
      do_post
      response.should redirect_to(user_path(@user))
    end
  end
end

describe AlbumsController, "POST /users/matt/albums/create when logged in as different user to the one in url" do
  before(:each) do
    @album = mock_model(Album, :save! => @album)
    @albums = [@album]
    @albums.stub!(:new).and_return(@album)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2, :albums => @albums)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2

    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, :user_id => 'matt'
  end

  it "should set flash error message" do
    do_post
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_post
    response.should be_redirect
  end
end

describe AlbumsController, "GET /users/matt/albums/test-album/edit when logged in as same user as in url" do
  before(:each) do
    @album = mock_model(Album, :save! => @album, :privacy_type => 'public')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :edit, :user_id => 'matt', :id => 'test-album'
  end

  it "should find the user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find the albums for the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should find the album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should assign the found album for the view" do
    do_get
    assigns[:album].should == @album
  end

  it "should be success" do
    do_get
    response.should be_success
  end
end

describe AlbumsController, "GET /users/matt/albums/test-album/edit when logged in as different user to the one in url" do
  before(:each) do
    @album = mock_model(Album, :save! => @album, :family_edit => false, :friends_edit => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2, :albums => @albums)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :edit, :user_id => 'matt', :id => 'test-album'
  end

  it "should create flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe AlbumsController, "PUT /users/matt/albums/test-album/update when logged in as same user as in url" do
  include AlbumSpecHelper

  before(:each) do
    @tag_list = mock_model(TagList)
    @album = mock_model(Album, :save! => @album, :update_attributes! => @album, :to_param => 'test-album',
                        :privacy_type => 'public', :tag_list= => @tag_list)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_put
    put :update, :user_id => 'matt', :id => 'test-album', :album => valid_album_attributes,
      :tags => 'test, test-photo, photo, matt'
  end

  it "should find the user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should find the albums for the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the album from the users albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_put
  end

  it "should add any supplied tags to the album" do
    @album.should_receive(:tag_list=).once.with('test, test-photo, photo, matt').and_return(@tag_list)
    do_put
  end
  
  it "should update the album with the new attributes" do
    @album.should_receive(:update_attributes!).once.and_return(@album)
    do_put
  end

  it "should create flash notice" do
    do_put
    flash[:notice].should == 'Album updated.'
  end

  it "should redirect to /users/matt/albums/test-album" do
    do_put
    response.should be_redirect
  end
end

describe AlbumsController, "PUT /users/matt/albums/test-album/update when logged in as different user to the one in url" do
  include AlbumSpecHelper

  before(:each) do
    @album = mock_model(Album, :save! => @album, :update_attributes => @album, :to_param => 'test-album')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_put
    put :update, :user_id => 'matt', :id => 'test-album', :album => valid_album_attributes
  end

  it "should populate flash error message" do
    do_put
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_put
    response.should be_redirect
  end
end

describe AlbumsController, "DELETE /users/matt/albums/test-album when logged in as same user as in url" do
  before(:each) do
    @album = mock_model(Album, :destroy => @album, :privacy_type => 'public')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@user)
    session[:user] = 1

    User.stub!(:find_by_login).and_return(@user)
  end

  def do_delete
    delete :destroy, :user_id => 'matt', :id => 'test-album'
  end

  it "should find the user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_delete
  end

  it "should find the albums for the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_delete
  end

  it "should find the album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_delete
  end

  it "should destroy the album" do
    @album.should_receive(:destroy).once.and_return(@album)
    do_delete
  end

  it "should redirect" do
    do_delete
    response.should be_redirect
  end
end

describe AlbumsController, "DELETE /users/matt/albums/test-album when logged in as different user to the one in url" do
  before(:each) do
    @album = mock_model(Album, :destroy => @album)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2

    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_delete
    delete :destroy, :user_id => 'matt', :id => 'test-album'
  end

  it "should populate flash error message" do
    do_delete
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_delete
    response.should be_redirect
  end
end
