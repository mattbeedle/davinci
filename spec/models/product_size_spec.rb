require File.dirname(__FILE__) + '/../spec_helper'

describe ProductSize do
  include ProductSizeSpecHelper

  before(:each) do
    @product_size = ProductSize.new
  end

  it "should not be valid without a product id" do
    @product_size.attributes = valid_product_size_attributes.except(:product_id)
    @product_size.should_not be_valid
    @product_size.product_id = 2
    @product_size.should be_valid
  end

  it "should not be valid without a numerical product id" do
    @product_size.attributes = valid_product_size_attributes.with(:product_id => 'a')
    @product_size.should_not be_valid
    @product_size.product_id = 2
    @product_size.should be_valid
  end

  it "should not be valid without a size id" do
    @product_size.attributes = valid_product_size_attributes.except(:size_id)
    @product_size.should_not be_valid
    @product_size.size_id = 3
    @product_size.should be_valid
  end

  it "should not be valid without a numerical size id" do
    @product_size.attributes = valid_product_size_attributes.with(:size_id => 'a')
    @product_size.should_not be_valid
    @product_size.size_id = 3
    @product_size.should be_valid
  end

  it "should be valid" do
    @product_size.attributes = valid_product_size_attributes
    @product_size.should be_valid
  end

  describe 'when product id and size id taken' do
    fixtures :product_sizes

    it "should not be valid" do
      @product_size.product_id = 1
      @product_size.size_id = 1
      @product_size.should_not be_valid
      @product_size.size_id = 2
      @product_size.should be_valid
    end
  end
end
