require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipsAlbum do
  before(:each) do
    @memberships_album = MembershipsAlbum.new
  end

  it "should be valid" do
    @memberships_album.should be_valid
  end
end
