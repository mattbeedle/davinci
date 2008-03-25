class PaymentsController < ApplicationController

  layout 'master'

  before_filter :login_required

  def new
  end

  def create
    # TODO actually process the payment stuff here

    # Extend the users membership by one year
    @current_user.last_paid_at = Time.now
    @current_user.membership_expires_on = Date.today + 1.year
    @current_user.save
    flash[:notice] = 'Thank you! You now have a whole extra year of membership...'
    redirect_to home_path(@current_user)
  end
end
