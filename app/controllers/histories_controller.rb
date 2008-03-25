class HistoriesController < ApplicationController

  layout 'master'

  before_filter :user, :only => [:show]
  before_filter :login_required

  def show
    check_user(@user, 'You do not have permission to view that page.')
    @photos = Photo.find(:all,
                         :select => 'photos.*',
                         :order => 'photos.created_at DESC',
                         :joins => 'LEFT JOIN albums ON albums.id = photos.album_id LEFT JOIN users ON users.id = albums.user_id',
                         :conditions => ['users.id = ?', @user.id])
    respond_to do |wants|
      wants.html
      wants.xml do
        render :xml => @photos.to_xml, :status => :success,
          :location => user_history_path(@user)
      end
    end
  end

  private

  def user
    @user = User.find_by_login(params[:user_id])
  end
end
