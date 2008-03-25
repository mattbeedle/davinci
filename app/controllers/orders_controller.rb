class OrdersController < ApplicationController

  layout 'master'

  before_filter :login_required

  def index
    @active_orders = @current_user.orders.active
    @past_orders = @current_user.orders.completed
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @current_user.orders.to_xml, :status => :success,
          :location => user_orders_path(@current_user)
      end
    end
  end

  def show
    @order = @current_user.orders.find_by_id(params[:id])
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @order.to_xml, :status => :success,
          :location => user_order_path(@current_user, @order)
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => 'Not found', :status => :error
      end
    end
  end
end
