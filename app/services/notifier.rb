# frozen_string_literal: true

class Notifier
  def self.prepare_notifications(topic:, action_name:)
    case topic
    when Move
      ::PrepareMoveNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name)
    end
    # when Person
    # It's built to support more notification `types`, it just happens we have only one right now
  end
end
