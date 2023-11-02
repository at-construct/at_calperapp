module EventOverlapChecker
  extend ActiveSupport::Concern

  def check_overlapping_events(user_ids, event, event_end = nil, event_start = nil)
    overlapping_events = []

    return overlapping_events if user_ids.blank? || event.blank?

    # user_idsが配列でない場合は配列に変換
    user_ids = Array(user_ids)

    Rails.logger.debug("Debugging transformed user_ids: #{user_ids.inspect}")

    # 変換前のイベントの開始時刻と終了時刻を取得（または引数から取得）
    start_time = event_start || event.start
    end_time = event_end || event.end

    # タイムゾーンをUTCに変換
    start_time_utc = start_time.in_time_zone('UTC')
    end_time_utc = end_time.in_time_zone('UTC')

    # ユーザーごとに重複チェック
    user_ids.each do |user_id|
      user_id = user_id.to_i # ユーザーIDは整数値に変換
      user = User.find_by(id: user_id)
      next unless user

      query = user.events.where.not(id: event.id).where(
        'start < ? AND "end" > ?', start_time_utc, end_time_utc
      )

      Rails.logger.debug("Executing SQL: #{query.to_sql}")
      overlapping_events += query
    end

    overlapping_events
  end
end