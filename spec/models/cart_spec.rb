require File.dirname(__FILE__) + '/../spec_helper'

describe Cart do
  describe 'with no line items' do
    before(:each) do
      @cart = Cart.new
    end

    it "should be empty" do
      @cart.items.should == []
      @cart.tax.should == 0.0
      @cart.total.should == 0.0
      @cart.shipping_cost.should == 0.0
    end

    it "empty? should return true" do
      @cart.empty?.should == true
    end

    it "should calculate tax_cost" do
      @cart.tax_cost.should == 0.0
    end

    describe 'adding an item' do
      before(:each) do
        @cart = Cart.new
        @item = mock_model(OrderLineItem, :quantity => 2, :unit_price => 10, :quantity= => @item)
        @photo = mock_model(Photo)
        @product = mock_model(Product)
        OrderLineItem.stub!(:for_product).and_return(@item)
      end

      it "should increase no of items on add_product" do
        @cart.add_product(@product, @photo, 1)
        @cart.items.length.should == 1
      end
    end
  end

  describe 'with one line item' do
    before(:each) do
      @cart = Cart.new
      @item = mock_model(OrderLineItem, :product_id => 1, :quantity => 3, :unit_price => 10,
                         :photo_id => 2, :quantity= => @item, :price= => @item)
      @photo = mock_model(Photo, :id => 2)
      @product = mock_model(Product, :id => 1, :price => 10)
      OrderLineItem.stub!(:for_product).and_return(@item)
      @cart.add_product(@product, @photo, 3)
    end

    it 'should decrease line item product quantity on remove product with quantity 1' do
      @cart.remove_product(@product, @photo, 1)
      @cart.items.find { |i| i.product_id == @product.id and i.photo_id == @photo.id }.quantity.should == 3
    end

    it 'should completely remove line item on remove product' do
      @cart.remove_product(@product, @photo)
      @cart.items.length.should == 0
    end

    it 'should increase quantity on add product with the same product' do
      @cart.add_product(@product, @photo, 1)
      @cart.items.find { |i| i.product_id == @product.id and i.photo_id == @photo.id }.quantity.should == 3
    end

    it 'should calculate total price' do
      @cart.total.should == 30
    end

    it "should caculate the total price of all line items" do
      @cart.line_items_total.should == 30
    end
  end

  describe 'with more than one line item' do
    before(:each) do
      @cart = Cart.new
      @item = mock_model(OrderLineItem, :product_id => 1, :quantity => 1)
    end
  end
end
