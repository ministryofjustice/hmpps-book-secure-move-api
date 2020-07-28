# frozen_string_literal: true

class PreparePersonEscortRecordNotificationsJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id:, action_name:)
    return unless (move = PersonEscortRecord.find(topic_id).profile.move)

    PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: action_name)
  end
end
