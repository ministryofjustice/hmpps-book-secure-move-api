# frozen_string_literal: true

class Notifier
  extend QueueDeterminer

  def self.prepare_notifications(topic:, action_name:)
    case topic
    when Move
      PrepareMoveNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, queue_as: move_queue_priority(topic))
    when Person
      PreparePersonNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, queue_as: :notifications_medium)
    when Profile
      PrepareProfileNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, queue_as: :notifications_medium)
    when PersonEscortRecord
      PreparePersonEscortRecordNotificationsJob.perform_later(topic_id: topic.id, queue_as: :notifications_medium)
    end
  end
end
