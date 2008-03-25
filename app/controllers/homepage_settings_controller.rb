class HomepageSettingsController < ApplicationController

  layout 'master'

  before_filter :login_required

  def edit
  end

  def update
    @current_user.homepage_content_preferences = params[:preferences]
    @current_user.save
    redirect_to index_path
  end
end
