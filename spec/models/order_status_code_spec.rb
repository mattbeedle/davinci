require File.dirname(__FILE__) + '/../spec_helper'

describe OrderStatusCode do
  before(:each) do
    @order_status_code = OrderStatusCode.new
  end

  it "should be valid" do
    @order_status_code.should be_valid
  end
end
