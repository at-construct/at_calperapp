class UsersController < ApplicationController
  def index
    render json: User.all
  end

  def show
    render json: User.find(params[:id])
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user
    else
      render json: user.errors, status: 422
    end
  end

  def excerpt
    #カレントユーザー以外の全てのユーザーを返す
    render json: User.where.not(id: current_user.id)
  end


  private

  def user_params
    #リクエストパラメーターのうち、permitで指定したものだけを受け取る
    params.require(:user).permit(:name, :email)
  end

end