require File.dirname(__FILE__) + '/../spec_helper'

describe OrderUser do
  include OrderUserSpecHelper

  before(:each) do
    @order_user = OrderUser.new
  end

  describe 'adding shipping address' do
    include OrderAddressSpecHelper

    def do_build
      @order_user.build_shipping_address(valid_order_address_attributes)
    end
  end

  describe 'validations' do
  end
end
