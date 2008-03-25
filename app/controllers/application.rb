# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'graticule'
require 'haml'
class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_flickr_session_id'

  include AuthenticatedSystem

  helper_method :is_owner?

  def is_owner?(user)
    current_user == user
  end

  def check_user(user, message='You do not have permission to do that.')
    unless is_owner?(user)
      flash[:error] = message
      redirect_back_or_default('/')
      return false
    end
  end
end
