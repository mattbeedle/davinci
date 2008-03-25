class InvitationsController < ApplicationController

  layout 'master'

  before_filter :login_required

  def new
    @user = User.find_by_login(params[:user_id])
    if @current_user == @user
      @invitation = Invitation.new
    else
      flash[:error] = 'You do not have permission to view that page.'
      redirect_back_or_default('/')
    end
  end

  def create
    @user = User.find_by_login(params[:user_id])
    if @current_user == @user
      @invitation = @user.invitations.new(params[:invitation])
      @invitation.save!
      Notifier.deliver_invitation(@invitation)
      respond_to do |wants|
        wants.html do
          flash[:notice] = 'Invitation sent.'
          redirect_to home_logged_in_path
        end
        wants.xml do
          render :xml => @invitation.to_xml(:include => [:sender, :receiver]), :status => :created
        end
      end
    else
      flash[:error] = 'You do not have permission to do that.'
      redirect_back_or_default('/')
    end
  end
end
