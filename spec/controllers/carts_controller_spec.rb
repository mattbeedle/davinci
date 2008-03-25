require File.dirname(__FILE__) + '/../spec_helper'

describe CartsController do
  before(:each) do
    @cart = mock_model(Cart)
  end

  describe 'GET /cart' do
    def do_get
      get :show
    end

    describe 'when cart does not exist' do
      before(:each) do
        Cart.stub!(:new).and_return(@cart)
      end

      it "should create a new cart" do
        Cart.should_receive(:new).once.and_return(@cart)
        do_get
      end
    end
  end

  describe 'PUT /cart' do
    before(:each) do
      Cart.stub!(:new).and_return(@cart)
      @cart.stub!(:add_product).and_return(@cart)
      @product = mock_model(Product, :id => 1)
      Product.stub!(:find_by_name).and_return(@product)
      @photo = mock_model(Photo)
      Photo.stub!(:find_by_permalink).and_return(@photo)
      @line_item = mock_model(OrderLineItem, :product_id => 2, :quantity= => @line_item)
      OrderLineItem.stub!(:for_product).and_return(@line_item)
    end

    def do_put
      put :update, :products => { 'lustre' => '1', 'gloss' => '2' }, :photo_id => 'test-photo'
    end

    it "should find the photo" do
      Photo.should_receive(:find_by_permalink).once.with('test-photo').and_return(@photo)
      do_put
    end

    it "should find the products" do
      Product.should_receive(:find_by_name).exactly(2).times.and_return(@product)
      do_put
    end

    it "should add the products to the cart" do
      @cart.should_receive(:add_product).exactly(2).times.and_return(@cart)
      do_put
    end

    it "should redirect to checkout" do
      do_put
      response.should redirect_to(cart_path)
    end
  end

  describe 'DELETE /cart' do
    before(:each) do
      @cart.stub!(:empty!).and_return(nil)
      session[:cart] = @cart
      @order = mock_model(Order, :destroy => @order)
      Order.stub!(:find).and_return(@order)
      session[:order] = 1
    end

    def do_delete
      delete :destroy
    end

    it "should empty the cart" do
      @cart.should_receive(:empty!).once.and_return(nil)
      do_delete
    end

    it "should find the order" do
      Order.should_receive(:find).once.with(1).and_return(@order)
      do_delete
    end

    it "should delete the order" do
      @order.should_receive(:destroy).once.and_return(@order)
      do_delete
    end

    it "should create a flash success message" do
      do_delete
      flash[:notice].should == 'Cart emptied.'
    end

    it "should redirect to cart page" do
      do_delete
      response.should redirect_to(cart_path)
    end
  end
end
