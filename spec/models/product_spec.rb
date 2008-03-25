require File.dirname(__FILE__) + '/../spec_helper'

describe Product do
  include ProductSpecHelper

  describe 'validations' do
    before(:each) do
      @product = Product.new
    end

    it "should not be valid without name" do
      @product.attributes = valid_product_attributes.except(:name)
      @product.should_not be_valid
      @product.name = 'test'
      @product.should be_valid
    end

    it 'should not be valid if price is non-numerical' do
      @product.attributes = valid_product_attributes.with(:price => 'a')
      @product.should_not be_valid
      @product.price = 10
      @product.should be_valid
    end

    it 'should not be valid if weight is non-numerical' do
      @product.attributes = valid_product_attributes.with(:weight => 'a')
      @product.should_not be_valid
      @product.weight = 1
      @product.should be_valid
    end

    it "should be valid" do
      @product.attributes = valid_product_attributes
      @product.should be_valid
    end
  end

  describe 'to_param' do
    before(:each) do
      @product = Product.new
    end

    it "should return product name" do
      @product.name = 'test'
      @product.to_param.should == 'test'
    end
  end
end
