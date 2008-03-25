class Admin::NotificationTypesController < ApplicationController

  layout 'master'

  before_filter :login_required
  permit 'administrator'

  def index
    @notification_types = NotificationType.find(:all)
  end

  def show
    @notification_type = NotificationType.find_by_id(params[:id])
  end

  def new
    @notification_type = NotificationType.new
  end

  def create
    @notification_type = NotificationType.new(params[:notification_type])
    @notification_type.save!
    redirect_to admin_notification_types_path
  end

  def edit
    @notification_type = NotificationType.find_by_id(params[:id])
  end

  def update
    @notification_type = NotificationType.find_by_id(params[:id])
    @notification_type.update_attributes params[:notification_type]
    flash[:notice] = 'Notification type updated.'
    redirect_to admin_notification_types_path
  end

  def destroy
    @notification_type = NotificationType.find_by_id(params[:id])
    @notification_type.destroy
    flash[:notice] = 'Notification type deleted.'
    redirect_to admin_notification_types_path
  end
end
