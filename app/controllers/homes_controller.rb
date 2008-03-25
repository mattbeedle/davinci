class HomesController < ApplicationController

  layout 'master'

  before_filter :login_required, :except => [:index, :contact, :update_stylesheet]

  def index
    redirect_to user_path(current_user) if logged_in?
  end

  def index_logged_in
  end

  def contact
  end

  def update_stylesheet
    session[:stylesheet] = params[:stylesheet] unless params[:stylesheet].blank?
    redirect_to index_path unless logged_in?
    redirect_to user_path(current_user) if logged_in? 
  end
end
