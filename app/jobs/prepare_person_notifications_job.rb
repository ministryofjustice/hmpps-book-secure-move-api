# frozen_string_literal: true

# This job is responsible for identifying the moves related to the specified person and then notifying via
# PrepareMoveNotificationsJob
class PreparePersonNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, queue_name: :notifications_medium)
    Person.find(topic_id).moves.find_each do |move|
      PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: action_name)
    end
  end
end
