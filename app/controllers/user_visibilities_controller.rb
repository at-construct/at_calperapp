class UserVisibilitiesController < ApplicationController
  before_action :set_user_visibility, only: [:update]


  def index
    @user_visibilities = UserVisibility.all
    # @user_visibilities = UserVisibility.where(user_id: params[:user_id])
    render json: @user_visibilities
  end


  def update
    if @user_visibility.update(user_visibility_params)
      render json: @user_visibility
    else
      render json: @user_visibility.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user_visibility
    @user_visibility = UserVisibility.find(params[:id])
  end

  def user_visibility_params
    params.require(:user_visibility).permit(:visibility)
  end
end