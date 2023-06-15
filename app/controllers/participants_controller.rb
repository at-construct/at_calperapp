class ParticipantsController < ApplicationController
  # def index
  #   # 予定参加者の一覧を返す
  #   participants = Participant.includes(:event, :user)
  #   participants_with_events_and_users = participants.as_json(include: { event: {}, user: { only: :name } })
  #   render json: participants_with_events_and_users

  #   #participantに紐づくeventの抜粋して返す
  #   # events = current_user.participants.map(&:event)
  #   # render json: events
  # end

  # def create
  #   event = Event.new(event_params)
  #   event.user_id = current_user.id
  #   if event.save
  #     user_ids = params[:user]
  #     if user_ids
  #       user_ids.each do |user_id|
  #         participant = Participant.new(event_id: event.id, user_id: user_id)
  #         participant.save
  #       end
  #     end
  #     render json: event.to_json
  #   else
  #     render json: event.errors, status: 422
  #   end
  # endz

  def event_excerpt
    #participantに紐づくeventの抜粋して返す
    events = current_user.participants.map(&:event)
    render json: events
  end

  # def user_excerpt
  #   participants = Participant.includes(:user)
  #   users = participants.map { |participant| participant.user.slice(:id, :name, :email) }
  #   render json: users
  # end

  def events_with_participants
    events = Event.includes(participants: :user)
    events_json = events.map do |event|
      event.as_json.merge(
        'user_name' => event.user.name,
        'participants' => event.participants.map { |p| p.user.name }
      )
    end
    render json: events_json
  end

  # def user_excerpt
  #   #カレントユーザー以外の全てのユーザーを返す
  #   render json: User.where.not(id: current_user.id)
  # end

  def all
    participants = Participant.all
    participant_events = participants.map do |participant|
      participant_event = participant.event.attributes
      participant_event["participant_id"] = participant.user_id
      participant_event
    end
    render json: participant_events
  end

  #改修してdevise_token_authを使おう(セキュリティ上) 一旦はこれを使う
  skip_before_action :verify_authenticity_token

  private

  def event_params
    params[:event] ? params.require(:event).permit(:name, :start, :end, :timed, :description, :color,:user_id) : {}
  end

end


