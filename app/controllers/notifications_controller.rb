class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index_with_participants_and_read_status
    user_events = current_user.events
    .select("events.*, notifications.id AS notification_id, CASE WHEN notifications.read THEN 'read' ELSE 'unread' END AS read_status")
    .joins("LEFT JOIN notifications ON notifications.event_id = events.id AND notifications.recipient_id = #{current_user.id}")
  
    participant_events = current_user.participants.includes(:event).map do |participant|
      event = participant.event
      notification = Notification.find_by(event_id: event.id, recipient_id: current_user.id)
      event.attributes.merge(
        "notification_id" => notification ? notification.id : nil,
        "read_status" => notification ? (notification.read ? 'read' : 'unread') : 'unread'
      )
    end
  
    all_events = participant_events
    render json: all_events.to_json
  end

  def mark_as_read
    puts "Received params: #{params.inspect}"
    notification = Notification.find_by(id: params.require(:id))
  
    if notification.nil?
      render json: { success: false, error: 'Notification not found' }, status: 404
      return
    end
    
    if notification.nil?
      render json: { success: false, error: 'Notification not found' }, status: 404
      return
    end
    
    if notification.recipient_id == current_user.id
      notification.update(read: true)
      render json: { success: true }
    else
      render json: { success: false, error: 'Unauthorized access' }, status: 403
    end
  end
  

  def unread
    notifications = Notification.where(recipient_id: current_user.id, read: false)
    render json: notifications
  end
  
  def unread_count
    count = Notification.where(recipient_id: current_user.id, read: false).count
    render json: { count: count }
  end

  def read_status
    notification = Notification.find_by(id: params[:id])
    if notification.nil?
      render json: { success: false, error: 'Notification not found' }, status: 404
      return
    end
  
    if notification.recipient_id == current_user.id
      # read_status パラメータによりtrueまたはfalseに設定
      notification.update(read: params[:is_read] == "true")
      render json: { success: true }
    else
      render json: { success: false, error: 'Unauthorized access' }, status: 403
    end
  end

  def read_notifications
    notifications = Notification.where(recipient_id: current_user.id, read: true).pluck(:id)
    render json: { ids: notifications }
  end
end
