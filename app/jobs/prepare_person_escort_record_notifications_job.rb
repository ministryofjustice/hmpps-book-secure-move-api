# frozen_string_literal: true

class PreparePersonEscortRecordNotificationsJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id:, action_name:)
    PersonEscortRecord.find(topic_id).profile.moves.find_each do |move|
      PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: action_name)
    end
  end
end
