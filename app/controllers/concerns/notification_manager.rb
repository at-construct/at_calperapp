module NotificationManager
  extend ActiveSupport::Concern

   def create_notification_and_participant(event, user_ids)
     user_ids.each do |user_id|
       unless Notification.exists?(event_id: event.id, recipient_id: user_id)
         Notification.create!(
           event_id: event.id,
           sender_id: current_user.id,
           recipient_id: user_id
         )
       end
   
       participant = Participant.new(event_id: event.id, user_id: user_id)
       participant.save
     end
   end
   
   def create_notification(participant, event) # eventパラメータの追加
     Notification.create(
       sender: current_user,
       recipient: participant,
       event: event, # @eventをeventに変更
       read: false
     )
   end

end