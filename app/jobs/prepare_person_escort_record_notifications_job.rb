# frozen_string_literal: true

class PreparePersonEscortRecordNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, **_)
    PersonEscortRecord.find(topic_id).profile.moves.find_each do |move|
      PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: action_name, queue_as: move_queue_priority(move))
    end
  end
end
