class OrderSessionsController < ApplicationController

  layout 'master'

  def new
  end

  def create
    order_user = OrderUser.authenticate(params[:email], params[:password])
    unless order_user.blank?
      session[:order_user] = order_user.id
      redirect_to session[:return_to]
      return false
    else
      flash[:error] = 'Email or password invalid.'
      render :action => :new
    end
  end

  def destroy
  end
end
