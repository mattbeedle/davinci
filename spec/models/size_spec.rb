require File.dirname(__FILE__) + '/../spec_helper'

describe Size do
  include SizeSpecHelper

  before(:each) do
    @size = Size.new
  end

  it "should not be valid without name" do
    @size.attributes = valid_size_attributes.except(:name)
    @size.should_not be_valid
    @size.name = '4 x 5'
    @size.should be_valid
  end

  it "should be valid" do
    @size.attributes = valid_size_attributes
    @size.should be_valid
  end
end
