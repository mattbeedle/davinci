require File.dirname(__FILE__) + '/../spec_helper'

describe ProductsController, 'GET /users/matt/albums/test-album/photos/test-photo/products' do
  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo')
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    @product = mock_model(Product)
    @products = [@product]
    Product.stub!(:find).and_return(@products)
  end

  def do_get
    get :index, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo'
  end

  it 'should find the specified user' do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it 'should assign the found user' do
    do_get
    assigns[:user].should == @user
  end

  it 'should find the albums belonging to the found user' do
    @user.should_receive(:albums).once.and_return(@albums)
    do_get
  end

  it 'should find the specified album from within the found albums' do
    @albums.should_receive(:find_by_permalink).once.with('test-album').and_return(@album)
    do_get
  end

  it 'should assign the found album' do
    do_get
    assigns[:album].should == @album
  end

  it 'should find the photos belonging to the found album' do
    @album.should_receive(:photos).once.and_return(@photos)
    do_get
  end

  it 'should find the specified photo from within the found photos' do
    @photos.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
    do_get
  end

  it 'should assign the found photo' do
    do_get
    assigns[:photo].should == @photo
  end

  it 'should be success' do
    do_get
    response.should be_success
  end

  it "should find the specified product" do
    Product.should_receive(:find).once.and_return(@products)
    do_get
  end

  it "should assign the found products" do
    do_get
    assigns[:products].should == @products
  end
end

describe ProductsController, 'Get /users/matt/albums/test-album/photos/test-photo/products/test-product' do
  before(:each) do
    @photo = mock_model(Photo, :to_param => 'test-photo')
    @photos = [@photo]
    @photos.stub!(:find_by_permalink).and_return(@photo)
    @album = mock_model(Album, :to_param => 'test-album', :photos => @photos)
    @albums = [@album]
    @albums.stub!(:find_by_permalink).and_return(@album)
    @user = mock_model(User, :to_param => 'matt', :albums => @albums)
    User.stub!(:find_by_login).and_return(@user)
    @product = mock_model(Product)
    Product.stub!(:find_by_name).and_return(@product)
  end

  def do_get
    get :show, :user_id => 'matt', :album_id => 'test-album', :photo_id => 'test-photo', :id => 'test-product'
  end

  it "should find the specified user" do
    User.should_receive(:find_by_login).once.with('matt').and_return(@user)
    do_get
  end

  it "should assign the found user" do
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

  it "should assign the found album" do
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

  it "should assign the photo" do
    do_get
    assigns[:photo].should == @photo
  end

  it "should find the product" do
    Product.should_receive(:find_by_name).once.with('test-product').and_return(@product)
    do_get
  end

  it "should assign the found product" do
    do_get
    assigns[:product].should == @product
  end
end
