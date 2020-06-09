# frozen_string_literal: true

class Notifier
  def self.prepare_notifications(topic:, action_name:)
    case topic
    when Move
      PrepareMoveNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name)
    when Person
      PreparePersonNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name)
    end
  end
end
