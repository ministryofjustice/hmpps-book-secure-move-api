# frozen_string_literal: true

class PrepareAssessmentNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, topic_class:, **_)
    assessment = topic_class.constantize.find(topic_id)
    return unless (move = assessment.move)

    PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: "confirm_#{topic_class.underscore}", queue_as: move_queue_priority(move))
  end
end
