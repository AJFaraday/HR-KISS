class ApplicationController < ActionController::Base
  protect_from_forgery

  #filter_parameter_logging :password, :password_confirmation

  helper_method :current_user_session, :current_user, :require_admin_user

  def index
    render :overview if current_user
  end

  def overview

  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    logger.debug "ApplicationController::require_user"
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_admin_user
    logger.debug "ApplicationController::require_admin_user"
    unless current_user and current_user.is_admin?
      store_location
      flash[:notice] = "You must be logged in as an admin user to access this page."
      redirect_to root_path
      return false
    end
  end

  def require_no_user
    logger.debug "ApplicationController::require_no_user"
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_path
      return false
    end
  end

  def store_location
    #session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    #redirect_to(session[:return_to] || default)
    #session[:return_to] = nil
  end

end
