require File.dirname(__FILE__) + '/../spec_helper'

describe OrderAccountType do
  before(:each) do
    @order_account_type = OrderAccountType.new
  end

  it "should be valid" do
    @order_account_type.should be_valid
  end
end
