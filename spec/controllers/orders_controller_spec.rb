require File.dirname(__FILE__) + '/../spec_helper'

describe OrdersController do

  describe "GET 'index'" do
    before :each do
      @order = mock_model(Order)
      @orders = [@order]
      Order.stub!(:find).and_return(@orders)
    end

    def do_get
      get :index
    end
  end
end
