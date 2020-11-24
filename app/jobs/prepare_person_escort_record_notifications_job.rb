# frozen_string_literal: true

class PreparePersonEscortRecordNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, **_)
    person_escort_record = PersonEscortRecord.find(topic_id)
    return unless (move = person_escort_record.move)

    PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: 'confirm_person_escort_record', queue_as: move_queue_priority(move))
  end
end
