class EventsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # イベントデータの一覧を返す
    # render json: Event.all
    # ログインした自身のイベントデータの一覧を返す
    render json: current_user.events.to_json
  end

  def index_with_participants
    user_events = current_user.events
    participant_events = current_user.participants.map(&:event)
    all_events = user_events + participant_events
    render json: all_events.to_json
  end

  def show
    # 指定したidのイベントデータを返す
    render json: Event.find(params[:id])
  end

  def create
    event = Event.new(event_params)
    event.user_id = current_user.id
    event.user_name = current_user.name
  
    user_ids = params[:participant]
    overlapping_events = []
  
    if user_ids
      user_ids.each do |user_id|
        user = User.find(user_id)
        overlapping_events += user.events.where.not(id: event.id).where('start < ? AND "end" > ?', event.end, event.start)
      end
    end
  
    if overlapping_events.empty?
      if event.save
        if user_ids
          user_ids.each do |user_id|
            participant = Participant.new(event_id: event.id, user_id: user_id)
            participant.save
          end
        end
        render json: event.to_json
      else
        render json: event.errors, status: 422
      end
    else
      render json: { error: 'The event overlaps with another one' }, status: 422
    end
  end
  
  def update
    puts "Update action started"
    event = Event.find(params[:id])
    user_ids = params[:user] || []
    overlapping_events = []
    
    user_ids.each do |user_id|
      user = User.find(user_id)
      overlapping_events += user.events.where.not(id: event.id).where('start < ? AND "end" > ?', event_params[:end], event_params[:start])
    end
    
    # 以下の処理も event 変数を使用する
    if overlapping_events.empty?
      current_user_ids = event.participants.map(&:user_id)
      added_user_ids = user_ids - current_user_ids
      removed_user_ids = current_user_ids - user_ids
    
      added_user_ids.each do |user_id|
        Participant.create(event_id: event.id, user_id: user_id)
      end
    
      if event.update(event_params)
        puts "Event successfully updated"
        render json: event.to_json
      else
        puts "Failed to update event"
        render json: event.errors, status: 422
      end
    else
      render json: { error: 'The event overlaps with another one' }, status: 422
    end
  end
      
  def destroy
    # 指定したidのイベントデータを削除する
    event = Event.find(params[:id])
    # 中間テーブルから、そのイベントに対する参加者情報を削除する
    event.participants.destroy_all
    event.destroy!
    render json: event.to_json
  end

  def all
    # イベントデータの一覧を返す
    render json: Event.all
  end
  
  # 改修してdevise_token_authを使おう(セキュリティ上) 一旦はこれを使う
  skip_before_action :verify_authenticity_token

private

def event_params
  params.require(:event).permit(:id, :name, :start, :end, :timed, :description, :color, :visibility, user: [:id, :name])
end

end
