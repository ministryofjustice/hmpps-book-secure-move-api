# frozen_string_literal: true

# This job is responsible for identifying the moves related to the specified profile and then notifying via
# PrepareMoveNotificationsJob
class PrepareProfileNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, **_)
    Profile.find(topic_id).moves.find_each do |move|
      PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name:, queue_as: move_queue_priority(move))
    end
  end
end
