require File.dirname(__FILE__) + '/../spec_helper'

describe PhotosController, "GET /users/matt/album/test-album/photos" do
  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:public).and_return(@photos)
    @album = mock_model(Album, :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :index, :user_id => 'matt', :album_id => 'test-album'
  end

  it "should find the user in the url" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should find the album in the url from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should find all the photos for the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get
  end

  it "should assign the found photos for the view" do
    do_get
    assigns[:photos].should == @photos
  end
end

describe PhotosController, "GET /users/matt/albums/test-album/photos/test-photo" do
  include PhotoSpecHelper

  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo', :resize! => @photo, :sepia! => @photo, :solarize! => @photo,
                        :posterize! => @photo, :despeckle! => @photo, :enhance! => @photo, :quantize! => @photo,
                        :charcoal! => @photo, :modulate! => @photo, :oil_paint! => @photo, :negate! => @photo,
                        :unsharp_mask! => @photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :unsharp_radius => 0.0,
                        :unsharp_sigma => 1.0, :unsharp_amount => 1.0, :unsharp_threshold => 0.05)
    @albums = [@albums]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get(parameters)
    get :show, parameters.merge({ :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo' })
  end

  it "should find the user specified in the url" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get(photo_effect_parameters)
  end

  it "should find the albums for the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get(photo_effect_parameters)
  end

  it "should find the albums specified in the url from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get(photo_effect_parameters)
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get(photo_effect_parameters)
  end

  it "should find the photo specified in the url from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should resize the photo if params[:size]" do
    @photo.should_receive(:resize!)
    do_get(photo_effect_parameters)
  end

  it "should apply album unsharp settings" do
    @photo.should_receive(:unsharp_mask!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not apply album unsharp amount is 0" do
    @album.stub!(:unsharp_amount).and_return(0)
    @album.should_not_receive(:unsharp_mask!)
    do_get(photo_effect_parameters)
  end

  it "should not resize the photo if params[:size] is blank" do
    @photo.should_not_receive(:resize!)
    do_get(photo_effect_parameters.except(:size))
  end

  it "should sepia the photo if params[:sepia][:threshold]" do
    @photo.should_receive(:sepia!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not sepia the photo if params[:sepia][:threshold] is blank" do
    @photo.should_not_receive(:sepia!)
    do_get(photo_effect_parameters.except(:sepia))
  end

  it "should solarize the photo if params[:solarize][:threshold]" do
    @photo.should_receive(:solarize!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not solarize the photo if params[:solarize][:threshold]" do
    @photo.should_not_receive(:solarize!)
    do_get(photo_effect_parameters.except(:solarize))
  end

  it "should posterize the photo if params[:posterize]" do
    @photo.should_receive(:posterize!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not posterize the photo if params[:posterize] is blank" do
    @photo.should_not_receive(:posterize!)
    do_get(photo_effect_parameters.except(:posterize))
  end

  it "should despeckle the photo if params[:despeckle]" do
    @photo.should_receive(:despeckle!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not despeckle the photo if params[:despeckle] blank" do
    @photo.should_not_receive(:despeckle!)
    do_get(photo_effect_parameters.except(:despeckle))
  end

  it "should enhance the photo if params[:enhance]" do
    @photo.should_receive(:enhance!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not enhance the photo if params[:enhance] blank" do
    @photo.should_not_receive(:enhance!)
    do_get(photo_effect_parameters.except(:enhance))
  end

  it "should quantize the photo if params[:quantize]" do
    @photo.should_receive(:quantize!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not quantize the photo if params[:quantize] blank" do
    @photo.should_not_receive(:quantize)
    do_get(photo_effect_parameters.except(:quantize))
  end

  it "should charcoal the photo if params[:charcoal]" do
    @photo.should_receive(:charcoal!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not charcoal the photo if params[:charcoal] blank" do
    @photo.should_not_receive(:charcoal!)
    do_get(photo_effect_parameters.except(:charcoal))
  end

  it "should modulate the photo if params[:modulate]" do
    @photo.should_receive(:modulate!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not modulate the photo if params[:modulate] blank" do
    @photo.should_not_receive(:modulate!)
    do_get(photo_effect_parameters.except(:modulate))
  end

  it "should oil paint the photo if params[:oil_paint]" do
    @photo.should_receive(:oil_paint!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not oil paint the photo if params[:oil_paint] blank" do
    @photo.should_not_receive(:oil_paint)
    do_get(photo_effect_parameters.except(:oil_paint))
  end

  it "should negate the photo if params[:negate]" do
    @photo.should_receive(:negate!).once.and_return(@photo)
    do_get(photo_effect_parameters)
  end

  it "should not negate the photo if params[:negate] blank" do
    @photo.should_not_receive(:negate!)
    do_get(photo_effect_parameters.except(:negate))
  end
end

describe PhotosController, "GET /users/matt/albums/test-album/photos/new" do
  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    Photo.stub!(:new).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_id).and_return(@user)
    User.stub!(:find_by_login).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :new, :user_id => 'matt', :album_id => 'test-album'
  end

  describe 'when logged in as same as user in url' do
    before(:each) do
      @user.stub!(:active?).and_return(true)
    end

    it "should find the user specified in the url" do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_get
    end

    it "should assign the current user for the view" do
      do_get
      assigns[:current_user].should == @user
    end

    it "should instantiate a new photo" do
      Photo.should_receive(:new).once.and_return(@photo)
      do_get
    end

    it "should assign the photo for the view" do
      do_get
      assigns[:photo].should == @photo
    end
  end

  describe 'when logged in and trial over/not paid' do
    before(:each) do
      @user.stub!(:active?).and_return(false)
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_get
    end

    it 'should check if the user is on trial or has paid' do
      @user.should_receive(:active?).once.and_return(true)
      do_get
    end

    it 'should create a flash error message' do
      do_get
      flash[:error].should == 'Your account appears to have expired.'
    end

    it 'should redirect to album page' do
      do_get
      response.should redirect_to(user_album_path(@user, @album))
    end
  end
end

describe PhotosController, "GET /users/matt/albums/test-album/photos/new when logged in as different user to one in url" do
  before(:each) do
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2

    @album = mock_model(Album)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :new, :user_id => 'matt', :album_id => 'test-album'
  end

  it "should populate flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe PhotosController, 'POST /users/matt/albums/test-album/photos/' do
  before(:each) do
    @photo = mock_model(Photo, :save! => @photo)
    @photos = [@photo]
    @photos.stub!(:build).and_return(@photo)
    @album = mock_model(Album, :photos => @photos, :to_param => 'test-album')
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, :user_id => 'matt', :album_id => 'test-album'
  end

  describe 'when logged in as same user as in url and account active' do
    before(:each) do
      @user.stub!(:active?).and_return(true)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end
  end

  describe 'when logged in as same user as in url but trial over and not paid' do
    before(:each) do
      @user.stub!(:active?).and_return(false)
      User.stub!(:find_by_id).and_return(@user)
      session[:user] = 1
    end

    it 'should find the specified user' do
      User.should_receive(:find_by_login).once.with('matt').and_return(@user)
      do_post
    end

    it 'should check if the user is active' do
      @user.should_receive(:active?).once.and_return(false)
      do_post
    end

    it 'should create a flash error message' do
      do_post
      flash[:error].should == 'Your account appears to have expired.'
    end

    it 'should redirect to the album page' do
      do_post
      response.should redirect_to(user_album_path(@user, @album))
    end
  end
end

describe PhotosController, "POST /users/matt/albums/test-album/photos/ when logged in as different user to one in url" do
  before(:each) do
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
    @photo = mock_model(Photo)
    @photos = [@photos]
    @album = mock_model(Album)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, :user_id => 'matt', :album_id => 'test-album'
  end

  it "should populate flash error message" do
    do_post
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_post
    response.should be_redirect
  end
end

describe PhotosController, "GET /users/matt/albums/test-album/photos/test-photo/edit when logged in as owner" do

  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    Photo.stub!(:new).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :family_edit => false, :friends_edit => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :is_my_friend? => false,
                       :is_my_family? => false)
    User.stub!(:find_by_id).and_return(@user)
    User.stub!(:find_by_login).and_return(@user)
    session[:user] = 1
  end

  def do_get
    get :edit, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(1).and_return(@user)
    do_get
  end

  it "should find the user in the url" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find the albums belonging to the the found user" do
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

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_get
  end

  it "should assign the photo for the view" do
    do_get
    assigns[:photo].should == @photo
  end
end

describe PhotosController,
  "GET /users/matt/albums/test-album/photos/test-photo/edit when logged in as different user to owner and not friend" do

  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    Photo.stub!(:new).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :family_edit => false,
                        :friends_edit => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :is_my_friend? => false,
                       :if_my_family? => false)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    User.stub!(:find_by_login).and_return(@user)
    session[:user] = 2
  end

  def do_get
    get :edit, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should populate flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_get
    response.should be_redirect
  end
end

describe PhotosController, 'GET /users/matt/albums/test-album/photos/test-photo/edit when logged in as friend of user and can edit' do
  before(:each) do
    @photo = mock_model(Photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :photos => @photos, :friends_edit => true, :family_edit => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :albums => @albums, :is_my_friend? => true, :is_my_family? => false,
                       :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :edit, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
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

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it "should assign the album for the view" do
    do_get
    assigns[:album].should == @album
  end

  it "should check if the album allows edits from friends" do
    @album.should_receive(:friends_edit).once.and_return(true)
    do_get
  end

  it "should check if the current user is a friend of the owner" do
    @user.should_receive(:is_my_friend?).once.with(@current_user).and_return(true)
    do_get
  end

  it "should find the photos belonging to the album" do
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
end

describe PhotosController, "PUT /users/matt/albums/test-album/photos/test-photo when logged in as owner" do
  include PhotoSpecHelper

  before(:each) do
    @photo = mock_model(Photo, :save! => @photo, :to_param => 'test-photo', :resize! => @photo, :sepia! => @photo,
                        :solarize! => @photo, :posterize! => @photo, :despeckle! => @photo, :enhance! => @photo,
                        :quantize! => @photo, :charcoal! => @photo, :modulate! => @photo, :oil_paint! => @photo,
                        :negate! => @photo, :resize! => @photo, :featured= => true, :tag_list= => @tag_list,
                        :update_attribute => @photo, :save_without_revision! => @photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    Photo.stub!(:new).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :friends_edit => true)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :is_my_friend? => false,
                       :is_my_family? => false)
    User.stub!(:find_by_id).and_return(@user)
    User.stub!(:find_by_login).and_return(@user)
    session[:user] = 1
  end

  def do_put(attributes=photo_effect_parameters)
    put :update, attributes.merge({ :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo',
    :tags => 'test, test tag, another tag'})
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(1).and_return(@user)
    do_put
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the specified album from within the found albums" do
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

  it "should resize the photo if params[:size]" do
    @photo.should_receive(:resize!).once.and_return(@photo)
    do_put
  end

  it "should not resize the photo if params[:size] blank" do
    @photo.should_not_receive(:resize!)
    do_put(photo_effect_parameters.except(:size))
  end

  it "should sepia the photo if params[:sepia]" do
    @photo.should_receive(:sepia!).once.and_return(@photo)
    do_put
  end

  it "should not sepia the photo if params[:sepia]" do
    @photo.should_not_receive(:sepia!)
    do_put(photo_effect_parameters.except(:sepia))
  end

  it "should solarize the photo if params[:solarize]" do
    @photo.should_receive(:solarize!).once.and_return(@photo)
    do_put
  end

  it "should not solarize the photo if params[:solarize] blank" do
    @photo.should_not_receive(:solarize!)
    do_put(photo_effect_parameters.except(:solarize))
  end

  it "should quantize the photo if params[:quantize]" do
    @photo.should_receive(:quantize!).once.and_return(@photo)
    do_put
  end

  it "should not quantize the photo if params[:quantize] blank" do
    @photo.should_not_receive(:quantize!)
    do_put(photo_effect_parameters.except(:quantize))
  end

  it "should posterize the photo if params[:posterize]" do
    @photo.should_receive(:posterize!).once.and_return(@photo)
    do_put
  end

  it "should not posterize the photo if params[:posterize] blank" do
    @photo.should_not_receive(:posterize)
    do_put(photo_effect_parameters.except(:posterize))
  end

  it "should charcoal the photo if params[:photo]" do
    @photo.should_receive(:charcoal!).once.and_return(@photo)
    do_put
  end

  it "should not charcoal the photo if params[:photo] blank" do
    @photo.should_not_receive(:charcoal!)
    do_put(photo_effect_parameters.except(:charcoal))
  end

  it "should despeckle the photo if params[:despeckle]" do
    @photo.should_receive(:despeckle!).once.and_return(@photo)
    do_put
  end

  it "should not despeckle the photo if params[:despeckle] blank" do
    @photo.should_not_receive(:despeckle!)
    do_put(photo_effect_parameters.except(:despeckle))
  end

  it "should enhance the photo if params[:enhance]" do
    @photo.should_receive(:enhance!).once.and_return(@photo)
    do_put
  end

  it "should not enhance the photo if params[:enhance] blank" do
    @photo.should_not_receive(:enhance!)
    do_put(photo_effect_parameters.except(:enhance))
  end

  it "should modulate the photo if params[:modulate]" do
    @photo.should_receive(:modulate!).once.and_return(@photo)
    do_put
  end

  it "should not modulate the photo if params[:modulate] blank" do
    @photo.should_not_receive(:modulate!)
    do_put(photo_effect_parameters.except(:modulate))
  end

  it "should oil paint the photo if params[:oil_paint]" do
    @photo.should_receive(:oil_paint!).once.and_return(@photo)
    do_put
  end

  it "should not oil paint the photo if params[:oil_paint] blank" do
    @photo.should_not_receive(:oil_paint!)
    do_put(photo_effect_parameters.except(:oil_paint))
  end

  it "should negate the photo if params[:negate]" do
    @photo.should_receive(:negate!).once.and_return(@photo)
    do_put
  end

  it "should not negate the photo if params[:negate] blank" do
    @photo.should_not_receive(:negate!)
    do_put(photo_effect_parameters.except(:negate))
  end

  it "should set the photo to featured if params[:featured]" do
    @photo.should_receive(:featured=).once.and_return(true)
    do_put(photo_effect_parameters.merge({ :featured => true }))
  end

  it "should set the tags if there are any supplied" do
    @photo.should_receive(:tag_list=).once.with('test, test tag, another tag').and_return(@tag_list)
    do_put
  end

  it "should create a flash notice" do
    do_put
    flash[:notice].should == 'Photo updated!'
  end

  it "should save the photo" do
    @photo.should_receive(:save!).once.and_return(@photo)
    do_put
  end
end

describe PhotosController,
  "PUT /users/matt/albums/test-album/photos/test-photo when logged in as different user to owner and not friend or family" do

  include PhotoSpecHelper

  before(:each) do
    @photo = mock_model(Photo, :save_without_revision! => @photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :photos => @photos, :friends_edit => false, :family_edit => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :is_my_friend? => false,
                       :is_my_family? => false)
    User.stub!(:find_by_login).and_return(@user)

    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_put
    put :update, photo_effect_parameters.merge({ :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo' })
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(2).and_return(@current_user)
    do_put
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should populate a flash error message" do
    do_put
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_put
    response.should be_redirect
  end
end

describe PhotosController, 'PUT /users/matt/albums/test-album/photos/test-photo when friend of owner and can edit' do
  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo', :save! => @photo, :save_without_revision! => @photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :friends_edit => true, :family_edit => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :is_my_friend? => true,
                       :is_my_family? => false)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_put
    put :update, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should find the albums belonging to the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_put
  end

  it "should check to see if the current user is friends with the owner" do
    @user.should_receive(:is_my_friend?).twice.with(@current_user).and_return(true)
    do_put
  end

  it "should check if friends can edit the album" do
    @album.should_receive(:friends_edit).once.and_return(true)
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
end

describe PhotosController, 'PUT /users/matt/albums/test-album/photos/test-photo when family of owner and can edit' do
  include PhotoSpecHelper

  before(:each) do
    @tag_list = mock_model(TagList)
    @photo = mock_model(Photo, :to_param => 'test-photo', :save! => @photo, :tag_list= => @tag_list,
                        :description= => 'this is a test description', :save_without_revision! => @photo)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :friends_edit => false, :family_edit => true)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums, :is_my_family? => true,
                       :is_my_friend? => false)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_put(parameters=photo_effect_parameters)
    put :update, { :user_id => 'matt', :album_id => 'test-album',
      :id => 'test-photo' }.merge(photo_effect_parameters).merge({ :tags => 'test, a test, tag',
                                                                 :description => 'this is a test description' })
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should find the albums belonging to the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_put
  end

  it "should check to see if the current user is family of the user" do
    @user.should_receive(:is_my_family?).twice.with(@current_user).and_return(true)
    do_put
  end

  it "should check if family can edit" do
    @album.should_receive(:family_edit).once.and_return(true)
    do_put
  end

  it "should find the photos for the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_put
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_put
  end

  it "should update the found photo's description"

  it "should update the found photo's tags" do
    @photo.should_receive(:tag_list=).once.with('test, a test, tag').and_return(@tag_list)
    do_put
  end

  it "should save the photo without a revision" do
    @photo.should_receive(:save_without_revision!).once.and_return(@photo)
    do_put
  end
end

describe PhotosController, "DELETE /users/matt/albums/test-album/photos/test-photo when logged in as same as user in url" do
  before(:each) do
    @photo = mock_model(Photo, :destroy => @photo)
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

  def do_delete
    delete :destroy, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(1).and_return(@user)
    do_delete
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_delete
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_delete
  end

  it "should find the specified album from within the found albums" do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_delete
  end

  it "should find the photos belonging to the found album" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_delete
  end

  it "should find the specified photo from within the found photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_delete
  end

  it "should delete the found photo" do
    @photo.should_receive(:destroy).once.and_return(@photo)
    do_delete
  end

  it "should create flash notification" do
    do_delete
    flash[:notice].should == 'Photo deleted.'
  end

  it "should redirect to users album photos" do
    do_delete
    response.should redirect_to(user_album_photos_path(@user, @album))
  end
end

describe PhotosController,
  "DELETE /users/matt/albums/test-album/photos/test-photo when logged in as different user to the one in url" do

  before(:each) do
    @photo = mock_model(Photo, :destroy => @photo)
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

  def do_delete
    delete :destroy, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should find the current user" do
    User.should_receive(:find_by_id).once.with(2).and_return(@current_user)
    do_delete
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_delete
  end

  it "should create a flash error message" do
    do_delete
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_delete
    response.should be_redirect
  end
end

describe PhotosController, 'GET /user/matt/albums/test-album/photos/test-photo/move_form when logged in as owner' do
  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo')
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
    get :move_form, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it "should assign the found albums for the view" do
    do_get
    assigns[:albums].should == @albums
  end
end

describe PhotosController, 'GET /user/matt/albums/test-album/photos/test-photo/move_form when not owner' do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_get
    get :move_form, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
  end

  it "should create flash error message" do
    do_get
    flash[:error].should == 'You do not have permission to view that page.'
  end

  it "should redirect to photo page" do
    do_get
    response.should redirect_to(user_album_photo_path('matt', 'test-album', 'test-photo'))
  end
end

describe PhotosController, 'PUT /users/matt/albums/test-album/photos/test-photo/move when owner' do
  before(:each) do
    @target_album = mock_model(Album, :to_param => 'target-album')
    Album.stub!(:find).and_return(@target_album)
    @photo = mock_model(Photo, :to_param => 'test-photo', :album= => @target_album, :save_without_revision! => @photo,
                        :featured= => false)
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
    put :move, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo', :target_album => { :id =>'2' }
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should find the albums belonging to the found user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_put
  end

  it "should find the specified album from within the found albums" do
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

  it "should find the target album" do
    Album.should_receive(:find).once.with('2').and_return(@target_album)
    do_put
  end

  it "should update the photo to the belong to the new album" do
    @photo.should_receive(:album=).once.with(@target_album).and_return(@target_album)
    do_put
  end

  it "should set the photo featured attribute to false" do
    @photo.should_receive(:featured=).once.with(false).and_return(false)
    do_put
  end

  it "should save the photo" do
    @photo.should_receive(:save_without_revision!).once.and_return(@photo)
    do_put
  end

  it "should create a flash success notice" do
    do_put
    flash[:notice] = 'Photo moved.'
  end

  it "should redirect to photo page" do
    do_put
    response.should redirect_to(user_album_photo_path('matt', 'target-album', 'test-photo'))
  end
end

describe PhotosController, 'PUT /users/matt/albums/test-album/photos/test-photo/move when not owner' do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_put
    put :move, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo', :target_album => { :id => '2' }
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_put
  end

  it "should create a flash error message" do
    do_put
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect to photo page" do
    do_put
    response.should redirect_to(user_album_photo_path('matt', 'test-album', 'test-photo'))
  end
end

describe PhotosController, 'GET /users/matt/albums/test-album/photos/test-photo/download' do
  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo', :album= => @target_album, :save! => @photo, :featured= => false,
                        :to_jpg! => @photo, :original_filename => 'test-photo.jpg')
    @photo.stub!(:data).and_return('kdsjfh2$"RSDFksadhfijew') # This is supposed to be binary data
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :download, :user_id => 'matt', :album_id => 'test-album', :id => 'test-photo'
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

  it "should find the photos belonging to the found albums" do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get
  end

  it "should find the specified photo from within the photos" do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_get
  end

  it "should be a success" do
    do_get
    response.should be_success
  end
end
