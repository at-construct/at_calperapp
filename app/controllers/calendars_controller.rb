class CalendarsController < ApplicationController
  # include Authenticatable
  # before_action :authenticate_with_token!
  before_action :authenticate_user!

  def index

    render json: Calendar.all

    # render json: current_user.calendars

    # token = cookies[:token]

    # rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))

    # begin
    #   decoded_token = JWT.decode(token, rsa_private, true, { algorithm: 'RS256' })
    # rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
    #   return render json: { message: 'unauthorized' }, status: :unauthorized
    # end

    # user_id = decoded_token.first["sub"]

    # user = User.find(user_id)

    # if user.nil?
    #   render json: { message: 'unauthorized' }, status: :unauthorized
    # else
    #   render json: current_user.calendars
    # end

  end

  def show
    render json: Calendar.find(params[:id])
  end

  def create
    params = calendar_params
    params[:user_id] = current_user.id
    calendar = Calendar.new(params)
    if calendar.save
      render json: calendar
    else
      render json: calendar.errors, status: 422
    end
    # binding.pry
    # raise params.inspect
    # raise calendar_params.inspect
  end

  def update
    calendar = Calendar.find(params[:id])
    if calendar.update(calendar_params)
      render json: calendar
    else
      render json: calendar.errors, status: 422
    end
  end

  def destroy
    calendar = Calendar.find(params[:id])
    calendar.destroy!
    render json: calendar
  end

  skip_before_action :verify_authenticity_token

  private
  def calendar_params
    params.require(:calendar).permit(:name, :color, :visibility, :user_id)
  end
  
end
