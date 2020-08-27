# frozen_string_literal: true

# This job is responsible for identifying the moves related to the specified profile and then notifying via
# PrepareMoveNotificationsJob
class PrepareProfileNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, queue_name: :notifications_medium)
    Profile.find(topic_id).moves.find_each do |move|
      PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: action_name)
    end
  end
end
