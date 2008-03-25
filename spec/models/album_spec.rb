require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  include AlbumSpecHelper

  before(:each) do
    @album = Album.new
  end

  it "should not be valid without name" do
    @album.attributes = valid_album_attributes.except(:name)
    @album.should_not be_valid
    @album.name = 'test'
    @album.should be_valid
  end

  it "should not be valid without a user id" do
    @album.attributes = valid_album_attributes.except(:user_id)
    @album.should_not be_valid
    @album.user_id = 1
    @album.should be_valid
  end

  it "should not be valid with non-numerical user id" do
    @album.attributes = valid_album_attributes.merge({:user_id => 'a'})
    @album.should_not be_valid
    @album.user_id = 1
    @album.should be_valid
  end

  it "should be valid" do
    @album.attributes = valid_album_attributes
    @album.should be_valid
  end
end
