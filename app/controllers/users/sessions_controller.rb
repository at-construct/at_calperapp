# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
    # devise_create
  end

  # def devise_create
    
    
    # token = TokenService.issue_by_password!(params[:email], params[:password])
    # cookies[:token] = token


    # user = User.find_by(email: params[:email])&.authenticate(params[:password])

    # payload = {
    #   iss: "cal_app", 
    #   sub:  @user.id, 
    #   exp: (DateTime.current + 1.days).to_i 
    # }

    
    # rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))

    
    # token = JWT.encode(payload, rsa_private, "RS256")

    
    # cookies[:token] = token
  # end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
