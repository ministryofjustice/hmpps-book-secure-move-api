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
      send_emails = action_name == 'amend_person_escort_record'
      PreparePersonEscortRecordNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, send_emails: send_emails, queue_as: move_queue_priority(topic.move))
    when YouthRiskAssessment
      PrepareYouthRiskAssessmentNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, send_emails: false, queue_as: move_queue_priority(topic.move))
    end
  end
end
