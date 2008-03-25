require File.dirname(__FILE__) + '/../spec_helper'

describe OrderAccount do
  include OrderAccountSpecHelper

  before(:each) do
    @order_account = OrderAccount.new
  end

  it "should be valid" do
    @order_account.attributes = valid_order_account_attributes
    @order_account.should be_valid
  end
end
