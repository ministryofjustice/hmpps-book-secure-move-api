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
      if action_name == 'amend_person_escort_record'
        PreparePersonEscortRecordNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, queue_as: move_queue_priority(topic.move))
      elsif action_name == 'handover_person_escort_record'
        PreparePersonEscortRecordNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name, send_emails: false, queue_as: move_queue_priority(topic.move))
      else
        PrepareAssessmentNotificationsJob.perform_later(topic_id: topic.id, topic_class: topic.class.name, queue_as: :notifications_medium)
      end
    when YouthRiskAssessment
      PrepareAssessmentNotificationsJob.perform_later(topic_id: topic.id, topic_class: topic.class.name, queue_as: :notifications_medium)
    end
  end
end
