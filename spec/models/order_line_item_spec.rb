require File.dirname(__FILE__) + '/../spec_helper'

describe OrderLineItem do
  before(:each) do
    @order_line_item = OrderLineItem.new
  end

  describe 'when adding an item' do
    before(:each) do
      @product = mock_model(Product, :id => 1, :price => 0.10)
      @photo = mock_model(Photo, :id => 1)
      @order_line_item = mock_model(OrderLineItem, :quantity => 1, :item => @product, :photo_id => @photo.id,
                                    :unit_price => @product.price)
    end
  end

  describe 'validations' do
    include OrderLineItemHelper

    it 'should not be valid without product id' do
      @order_line_item.attributes = valid_order_line_item_attributes.except(:product_id)
      @order_line_item.should_not be_valid
      @order_line_item.product_id = 1
      @order_line_item.should be_valid
    end

    it 'should not be valid without order id' do
      @order_line_item.attributes = valid_order_line_item_attributes.except(:order_id)
      @order_line_item.should_not be_valid
      @order_line_item.order_id = 1
      @order_line_item.should be_valid
    end

    it 'should not be valid without a photo id' do
      @order_line_item.attributes = valid_order_line_item_attributes.except(:photo_id)
      @order_line_item.should_not be_valid
      @order_line_item.photo_id = 1
      @order_line_item.should be_valid
    end

    it 'should not be valid without quantity' do
      @order_line_item.attributes = valid_order_line_item_attributes.except(:quantity)
      @order_line_item.should_not be_valid
      @order_line_item.quantity = 1
      @order_line_item.should be_valid
    end

    it 'should not be valid without a numerical quantity' do
      @order_line_item.attributes = valid_order_line_item_attributes.with(:quantity => 'a')
      @order_line_item.should_not be_valid
      @order_line_item.quantity = 1
      @order_line_item.should be_valid
    end

    it 'should not be valid without a unit price' do
      @order_line_item.attributes = valid_order_line_item_attributes.except(:unit_price)
      @order_line_item.should_not be_valid
      @order_line_item.unit_price = 0.0
      @order_line_item.should be_valid
    end

    it 'should not be valid without a numerical quantity' do
      @order_line_item.attributes = valid_order_line_item_attributes.with(:quantity => 'a')
      @order_line_item.should_not be_valid
      @order_line_item.quantity = 1
      @order_line_item.should be_valid
    end

    it "should be valid" do
      @order_line_item.attributes = valid_order_line_item_attributes
      @order_line_item.should be_valid
    end
  end
end
