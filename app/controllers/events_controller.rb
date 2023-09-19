class EventsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    render json: current_user.events.to_json
  end

  def my_events_with_participants
    user_events = current_user.events
    participant_events = current_user.participants.includes(:event).map(&:event)
    all_events = user_events + participant_events
    render json: { events: all_events, current_user: current_user }
  end

  def show
    # 指定したidのイベントデータを返す
    render json: Event.find(params[:id])
  end

  def create
    ActiveRecord::Base.transaction do
      event = Event.new(event_params)
      event.user_id = current_user.id
      event.user_name = current_user.name
  
      user_ids = params[:participant].map(&:to_i)
      overlapping_events = check_overlapping_events(user_ids, event)
  
      if overlapping_events.empty?
        event.save!
        create_notification_and_participant(event, user_ids) if user_ids
        render json: event.to_json
      else
        render json: { overlapping_events: overlapping_events }, status: 422
        raise ActiveRecord::Rollback
      end
    end
  rescue => e
    render json: { error: e.message }, status: 500
  end
  
  def update
    event = Event.find(params[:id].to_i)
    # イベントの現在の参加者情報を取得
    current_participants = event.participants
    current_user_ids = current_participants.map(&:user_id)
    Rails.logger.debug "Current Participants before calling manage_participants: #{current_participants.map(&:user_id).inspect}"
    
    # ここでparams[:user]からuser_idsを取得
    # params[:user] がハッシュか配列かに応じて処理を変更
    user_ids = if params[:user].is_a?(Array)
      params[:user].map { |user| user.is_a?(ActionController::Parameters) ? user["id"].to_i : user }
    elsif params[:user].is_a?(Hash)
      params[:user].values.map(&:to_i)
    else
      []
    end
    
    # 重複するイベントのチェック
    overlapping_events = check_overlapping_events(user_ids, event, params[:end], params[:start])
    if overlapping_events.empty?
      current_user_ids = event.participants.map(&:user_id)
      added_user_ids = user_ids - current_user_ids
      removed_user_ids = current_user_ids - user_ids
      # 参加者の追加と削除
      manage_participants(event, added_user_ids, removed_user_ids, current_participants)
      # イベントの更新
      if event.update(event_params)
        render json: event.to_json
      else
        render json: event.errors, status: 422
      end
    else
      render json: { error: 'The event overlaps with another one', overlapping_events: overlapping_events }, status: 422
    end
  end
    
  def confirm_duplicate_event
    event = Event.new(event_params)
    event.user_id = current_user.id
    event.user_name = current_user.name
    user_ids = params[:participant].map(&:to_i)
    overlapping_events = []
    if user_ids
      user_ids.each do |user_id|
        user = User.find(user_id)
        overlapping_events += user.events.where('start < ? AND "end" > ?', event.end, event.start)
      end
    end
    if overlapping_events.empty?
      render json: event.to_json
    else
      puts "Overlapping events: #{overlapping_events}"
      render json: { overlapping_events: overlapping_events }, status: 422
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

  def selected_user_events
    group_user_id = params[:group_user_id]
  
    # group_user_idに基づいてイベントをフィルタリング
    filtered_events = Event.where(user_id: group_user_id)
  
    # 参加者のイベントもフィルタリング（必要であれば）
    participant_events = Participant.includes(:event).where(user_id: group_user_id).map(&:event)
  
    # 結合と重複削除（必要であれば）
    all_events = filtered_events + participant_events
    all_events.uniq!
  
    # JSONでレンダリング
    render json: { events: all_events }
  end

  # 改修してdevise_token_authを使おう(セキュリティ上) 一旦はこれを使う
  skip_before_action :verify_authenticity_token

  private
  def check_overlapping_events(user_ids, event, event_end = nil, event_start = nil)
    overlapping_events = []
    # user_ids が nil または空の場合、空の配列を返す
    return overlapping_events if user_ids.nil? || user_ids.empty?

    # user_ids の形式を確認して適切な形に変換
    if user_ids.is_a?(Array)
      user_ids = user_ids.map { |id| {'id' => id} }
    elsif user_ids.is_a?(Hash)
      user_ids = user_ids.values
    end
    puts "Debugging transformed user_ids: #{user_ids.inspect}"

    user_ids.each do |user_id_hash|
      actual_user_id = user_id_hash["id"].to_i
      user = User.find_by(id: actual_user_id)
      next unless user
      overlapping_events += user.events.where.not(id: event.id).where('start < ? AND "end" > ?', event_end || event.end, event_start || event.start)
    end
  
    overlapping_events
  end
    
  def create_notification_and_participant(event, user_ids)
    user_ids.each do |user_id|
      Notification.create!(
        event_id: event.id,
        sender_id: current_user.id,
        recipient_id: user_id
      )
      
      participant = Participant.new(event_id: event.id, user_id: user_id)
      participant.save
    end
  end

  def manage_participants(event, added_user_ids, removed_user_ids, current_participants)
    # 追加された参加者の処理
    added_user_ids.each do |user_info|
      user_id = user_info # この部分は本当に正しいか要確認。user_info がすでに id だけでなく、他の情報も持っている可能性がある
      begin
        Participant.create!(event_id: event.id, user_id: user_id)
      rescue => e
        # 例外が発生した場合に、その情報をログに出力
        Rails.logger.debug "Failed to add participant with user_id: #{user_id}. Error: #{e.message}"
      end
    end
  
    # 削除された参加者の処理
    removed_user_ids.each do |user_id|
      participant = current_participants.find { |p| p.user_id == user_id }
      if participant
        participant.destroy
        Rails.logger.debug "Successfully removed participant with user_id: #{user_id}"
      else
        Rails.logger.debug "No participant found with user_id: #{user_id}"
      end
    end
  end
    

  def record_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end

  def event_params
    params.require(:event).permit(:id, :name, :start, :end, :timed, :description, :color, user: [:id, :name], participant: [:id, :name])
  end
end