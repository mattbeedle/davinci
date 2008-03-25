require File.dirname(__FILE__) + '/../spec_helper'

describe OrderShippingType do
  before(:each) do
    @order_shipping_type = OrderShippingType.new
  end

  it "should be valid" do
    @order_shipping_type.should be_valid
  end
end
