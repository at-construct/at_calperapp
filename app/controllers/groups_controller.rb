class GroupsController < ApplicationController

  def index
    groups = Group.all
    groups_with_users_and_calendars = groups.as_json(include: [:user, :calendar])
    render json: groups_with_users_and_calendars
  end

  def new
    @group = current_user.groups.build
  end

  def create
    @group = current_user.groups.(group_params)
  end

  private
    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:group_name)
    end
end
