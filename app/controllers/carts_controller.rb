class CartsController < ApplicationController

  layout 'master'

  before_filter :login_required, :only => [:checkout, :billing, :set_billing, :shipping]

  def show
    @cart = find_cart
  end

  def edit
  end

  def update
    # Find the cart
    @cart = find_cart

    # find the photo in question
    photo = Photo.find_by_permalink(params[:photo_id])

    # Find the requested products and add them to the cart
    for product in params[:products]
      @cart.add_product(Product.find_by_name(product[0]), photo, product[1].to_i)
    end

    # continue with cart process
    redirect_to cart_path
  end

  def destroy
    # Find the cart
    cart = find_cart

    # Empty the cart
    cart.empty!

    # Find the order
    order = find_order

    # Delete the order, if it exists
    order.destroy unless order.blank?

    # Create a flash message to inform the user
    flash[:notice] = 'Cart emptied.'

    # Go back to the cart page
    redirect_to cart_path
  end

  # Basically creates the order and adds it to the session
  def checkout
    # Find the order
    @order = find_order

    if @order.nil?
      status_code = OrderStatusCode.find_by_name('CART')
      @order = Order.create(:user => @current_user, :order_status_code => status_code)
      session[:order] = @order.id
    end

    # Find the cart
    @cart = find_cart

    # Add the cart items to the order and save
    @order.order_line_items = @cart.items
    @order.save!

    # continue with order process
    redirect_to billing_cart_path
  end

  def billing
    # Find the order
    @order = find_order
  end

  def set_billing
    # Find the order
    @order = find_order

    # If the order is not found, redirect
    if @order.blank?
      # TODO set flash error here
      flash[:error] = "We don't appear to be able to find your order."
      redirect_to cart_path
      return false
    end

    @billing_address = @order.build_billing_address params[:billing_address]
    if params[:same]
      @shipping_address = @order.build_shipping_address params[:billing_address]
    else
      @shipping_address = @order.build_shipping_address params[:shipping_address]
    end
    @order_account = @order.build_order_account params[:order_account]

    # This line is just to prevent order account post details from being lost if address validation fails
    @order_account = OrderAccount.new params[:order_account]

    @order.save!

    # continue with order process
    redirect_to shipping_cart_path

  rescue ActiveRecord::RecordInvalid
    render :action => :billing
  end

  def shipping
    @order = find_order

    # Find all shipping types for form
    country = @order.billing_address.country
    if country == 'united states of america' or country == 'canada'
      @order_shipping_types = OrderShippingType.find(:all,
                                                     :conditions => ['is_domestic = ?', true])
    else
      @order_shipping_types = OrderShippingType.find(:all,
                                                     :conditions => ['is_domestic = ?', false])
    end
  end

  def set_shipping
    # Find the shipping type
    order_shipping_type = OrderShippingType.find(params[:order_shipping_type_id])

    # Find the order
    @order = find_order

    # Set the shipping type
    @order.order_shipping_type = order_shipping_type
    @order.save!

    # continue with order process
    redirect_to show_order_cart_path
    
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Please select a shipping type.'
    redirect_to shipping_cart_path
  end

  def show_order
    # Find the order
    @order = find_order
  end

  def confirm_order
    # Find the order
    order = find_order

    # Change the status
    order.order_status_code = OrderStatusCode.find_by_name('ON HOLD - AWAITING PAYMENT')

    # Save the order
    order.save!

    # TODO deal with payment here

    # Display the order
    flash[:notice] = "Thank you for your order."
    redirect_to order_path(order)
  end

  private
  def find_cart
    session[:cart] ||= Cart.new
    session[:cart]
  end

  def find_order
    Order.find session[:order]
  rescue
    return nil
  end
end
