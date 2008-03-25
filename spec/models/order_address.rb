require File.dirname(__FILE__) + '/../spec_helper'

describe OrderAddress do
  before(:each) do
    @order_address = OrderAddress.new
  end

  describe 'validations' do
    include OrderAddressSpecHelper

    it "should not be valid without street" do
      @order_address.attributes = valid_order_address_attributes.except(:street)
      @order_address.should_not be_valid
      @order_address.street ='test'
      @order_address.should be_valid
    end

    it "should not be valid without a postal code" do
      @order_address.attributes = valid_order_address_attributes.except(:postal_code)
      @order_address.should_not be_valid
      @order_address.postal_code = 'BR3 4DA'
      @order_address.should be_valid
    end

    it "should not be valid without a valid postal code" do
      @order_address.attributes = valid_order_address_attributes.with(:postal_code => 'asf')
      @order_address.should_not be_valid
      @order_address.postal_code = 'BR3 4DA'
      @order_address.should be_valid
    end

    it "should not be valid without a country id" do
      @order_address.attributes = valid_order_address_attributes.except(:country_id)
      @order_address.should_not be_valid
      @order_address.country_id = 1
      @order_address.should be_valid
    end

    it "should not be valid without a numerical country id" do
      @order_address.attributes = valid_order_address_attributes.with(:country_id => 'a')
      @order_address.should_not be_valid
      @order_address.country_id = 1
      @order_address.should be_valid
    end

    it "should be valid" do
      @order_address.attributes = valid_order_address_attributes
      @order_address.should be_valid
    end
  end
end
