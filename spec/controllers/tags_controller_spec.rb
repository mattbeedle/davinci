require File.dirname(__FILE__) + '/../spec_helper'

describe TagsController do

  describe "GET /tags/test" do
    before(:each) do
      @photo = mock_model(Photo)
      @photos = [@photo]
      Photo.stub!(:find_tagged_with).and_return(@photos)
      @album = mock_model(Album)
      @albums = [@album]
      Album.stub!(:find_tagged_with).and_return(@albums)
    end

    def do_get
      get :show, :id => 'test'
    end

    it 'should find the photos tagged with the specified tag' do
      Photo.should_receive(:find_tagged_with).once.with('test').and_return(@photos)
      do_get
    end

    it 'should assign the found photos' do
      do_get
      assigns[:photos].should == @photos
    end

    it 'should find the albums tagged with the specified tag' do
      Album.should_receive(:find_tagged_with).once.with('test').and_return(@albums)
      do_get
    end

    it 'should assign the found albums' do
      do_get
      assigns[:albums].should == @albums
    end
  end
end
