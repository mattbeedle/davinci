require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController, 'GET /users/matt/albums/test-album/photos/test-photos/comments' do
  before(:each) do
    @comment = mock_model(Comment)
    @comments = [@comment]
    @comments.stub!(:paginate).and_return(@comments)
    @photo = mock_model(Photo, :to_param => 'test-photo', :comments => @comments)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :index, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should assign the found user for the view" do
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

  it "should assign the found album for the view" do
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

  it "should assign the found photo for the view" do
    do_get
    assigns[:photo].should == @photo
  end

  it "should find the comments belonging to the found photo" do
    @photo.should_receive(:comments).once.and_return(@comments)
    do_get
  end

  it "should paginate the comments" do
    @comments.should_receive(:paginate).once.and_return(@photos)
    do_get
  end

  it "should assign the comments for the view" do
    do_get
    assigns[:comments].should == @comments
  end
end

describe CommentsController, 'GET /users/matt/albums/test-album/photos/test-photo/comments/new' do
  before(:each) do
    @comment = mock_model(Comment, :id => nil)
    @comments = [@comment]
    @comments.stub!(:paginate).and_return(@comments)
    @photo = mock_model(Photo, :to_param => 'test-photo', :comments => @comments)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :commentable => true)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :new, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo'
  end

  it "instantiate a new comment" do
    Comment.should_receive(:new).once.and_return(@comment)
    do_get
  end

  it "should assign the comment for the view" do
    do_get
    assigns[:comment].should == @comment
  end
end

describe CommentsController, 'GET /users/matt/albums/test-album/photos/test-photo/comments/new when commenting off' do
  before(:each) do
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :commentable => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_get
    get :new, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo'
  end

  it "should check if album is commentable" do
    @album.should_receive(:commentable).once.and_return(false)
    do_get
  end

  it "should create a flash error message" do
    do_get
    flash[:error].should == 'Commenting is turned off for photos in this album.'
  end

  it "should redirect to photo page" do
    do_get
    response.should redirect_to(user_album_photo_path(@user, @album, 'test-photo'))
  end
end

describe CommentsController,
  'POST /users/matt/albums/test-album/photos/test-photo/comments when logged in and commenting on' do
  include CommentSpecHelper

  before(:each) do
    @comment = mock_model(Comment, :save! => @comment, :user= => @user)
    @comments = [@comment]
    @comments.stub!(:paginate).and_return(@comments)
    @comments.stub!(:build).and_return(@comment)
    @photo = mock_model(Photo, :to_param => 'test-photo', :comments => @comments)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :commentable => true)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_post
    post :create, { :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo' }.merge(:comment => {:body => 'some text'})
  end

  it "should check if the album is commentable" do
    @album.should_receive(:commentable).once.and_return(true)
    do_post
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_post
  end

  it "should find the albums belonging to the user" do
    @user.should_receive(:albums).once.and_return(@albums)
    do_post
  end

  it "should find the specified album from within the albums" do
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

  it "should find the comments belonging to the found photo" do
    @photo.should_receive(:comments).once.and_return(@comments)
    do_post
  end

  it "should build a new comment" do
    @comments.should_receive(:build).once.and_return(@comment)
    do_post
  end

  it "should set the user" do
    @comment.should_receive(:user=).once.with(@current_user).and_return(@current_user)
    do_post
  end

  it "should save the comment" do
    @comment.should_receive(:save!).once.and_return(@comment)
    do_post
  end

  it "should create a flash success notice" do
    do_post
    flash[:notice].should == 'Comment added.'
  end

  it "should redirect to photo" do
    do_post
    response.should redirect_to(user_album_photo_path(@user, @album, @photo))
  end
end

describe CommentsController,
  'POST /users/matt/albums/test-album/photos/test-photo/comments when not logged in and commenting on' do
  before(:each) do
    @comment = mock_model(Comment, :save! => @comment, :user_id= => 0)
    @comments = [@comment]
    @comments.stub!(:paginate).and_return(@comments)
    @comments.stub!(:build).and_return(@comment)
    @photo = mock_model(Photo, :to_param => 'test-photo', :comments => @comments)
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :commentable => true)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, { :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo' }.merge(:comment => {:body => 'some text'})
  end

  it 'should set the user id to 0 (guest)' do
    @comment.should_receive(:user_id=).once.with(0).and_return(0)
    do_post
  end
end

describe CommentsController, 'POST /users/matt/albums/test-album/photos/test-photo/comments when commenting off' do
  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo', :comments => @comments)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos, :commentable => false)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :id => 1, :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
  end

  def do_post
    post :create, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo',
      :comment => { :body => 'kashfjkewhfkj' }
  end

  it "should check if album is commentable" do
    @album.should_receive(:commentable).once.and_return(false)
    do_post
  end

  it "should create flash error message" do
    do_post
    flash[:error].should == 'Commenting is turned off for photos in this album.'
  end

  it "should redirect to photo page" do
    do_post
    response.should redirect_to(user_album_photo_path(@user, @album, @photo))
  end
end

describe CommentsController, 'DELETE /user/matt/albums/test-album/photos/test-photo/comments/1 when logged in as owner' do
  before(:each) do
    @comment = mock_model(Comment, :destroy => @comment, :user_id= => 0)
    @comments = [@comment]
    @comments.stub!(:find).and_return(@comment)
    @photo = mock_model(Photo, :to_param => 'test-photo', :comments => @comments)
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

  def do_delete
    delete :destroy, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 1
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_delete
  end

  it "should find the albums belonging to the specified user" do
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

  it "should find the comments belonging to the found photo" do
    @photo.should_receive(:comments).once.and_return(@comments)
    do_delete
  end

  it "should find the specified comment from within the found comments" do
    @comments.should_receive(:find).once.with('1').and_return(@comment)
    do_delete
  end

  it "should delete the found comment" do
    @comment.should_receive(:destroy).once.and_return(true)
    do_delete
  end

  it "should create a flash success message" do
    do_delete
    flash[:notice].should == 'Comment deleted.'
  end

  it "should redirect to photo" do
    do_delete
    response.should redirect_to(user_album_photo_path(@user, @album, @photo))
  end
end

describe CommentsController,
  'DELETE /users/matt/albums/test-album/photos/test-photo/comments/1 when logged in but not as owner' do
  before(:each) do
    @user = mock_model(User, :to_param => 'matt', :id => 1)
    User.stub!(:find_by_login).and_return(@user)
    @current_user = mock_model(User, :to_param => 'sam', :id => 2)
    User.stub!(:find_by_id).and_return(@current_user)
    session[:user] = 2
  end

  def do_delete
    delete :destroy, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 1
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_delete
  end

  it "should create flash error message" do
    do_delete
    flash[:error].should == 'You do not have permission to do that.'
  end

  it "should redirect" do
    do_delete
    response.should be_redirect
  end
end
