class NotificationsController < ApplicationController

  layout 'master'

  before_filter :login_required

  def index
    @received_notifications = @current_user.received_notifications.latest
    @received_notifications.each do |notification|
      notification.mark_as_read
    end
    respond_to do |wants|
      wants.html
    end
  end

  def show
    @notification = @current_user.notifications.find_by_id(params[:id])

    if @notification.blank?
      respond_to do |wants|
        wants.html do
          flash[:error] = 'That notification could not be found.'
          redirect_to notifications_path
          return false
        end
        wants.xml do
          render :xml => @notification.to_xml, :status => :success,
            :location => notification_path(@notification)
        end
      end
    end
  end
end
