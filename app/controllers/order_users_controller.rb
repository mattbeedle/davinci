class OrderUsersController < ApplicationController

  layout 'master'

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:order_user]
    @user.has_role  'order-user'
    @user.save!
    flash[:notice] = 'You have registered.'
    redirect_to session[:return_to] || cart_path
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
end
