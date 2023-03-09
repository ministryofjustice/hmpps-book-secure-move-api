# frozen_string_literal: true

class UpdateMoveNomisDataJob < ApplicationJob
  def perform(move_id:)
    Rails.logger.info("Updating data from NOMIS for move #{move_id}")

    move = Move.find(move_id)
    return if move.person.nil?

    move.person.update_nomis_data

    Notifier.prepare_notifications(topic: move, action_name: 'update')

    Rails.logger.info("Completed updating data from NOMIS for move #{move_id}")
  end
end
