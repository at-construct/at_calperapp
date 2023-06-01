class ApplicationController < ActionController::Base
  include ActionController::Cookies
  before_action :set_cache_headers

  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  rescue_from AuthenticationError, with: :render_unauthorized_error
  
  def render_unauthorized_error
    raise AuthenticationError
  end

  def after_sign_in_path_for(resource)
    root_path(resource)
  end

  private

  def configure_permitted_parameters
    # 新規登録時(sign_up時)にnameというキーのパラメーターを追加で許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name]) 
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
