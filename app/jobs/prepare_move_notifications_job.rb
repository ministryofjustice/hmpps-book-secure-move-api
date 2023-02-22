# frozen_string_literal: true

class PrepareMoveNotificationsJob < PrepareBaseNotificationsJob
private

  def find_topic(topic_id)
    Move.find(topic_id)
  end

  def associated_move(topic)
    topic
  end

  def build_notifications(subscription, type_id, topic, action_name)
    notifications = []

    if %w[update update_status].include?(action_name) &&
        topic.notifications.where(event_type: 'create_move', notification_type_id: type_id).none?
      notifications << build_notification(subscription, type_id, topic, 'create')
    end

    notifications << build_notification(subscription, type_id, topic, action_name)
  end
end
