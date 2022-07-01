# frozen_string_literal: true

class NotifyUnnotifiedMovesWorker
  include Sidekiq::Worker

  def perform
    Move.where(date: Time.zone.today..Time.zone.tomorrow)
        .where.not(status: %w[proposed cancelled])
        .reject { |m| m.notifications.map(&:event_type).include?('create_move') }
        .each do |move|
      unless move.generic_events.pluck(:type).include?('GenericEvent::MoveRequested')
        Rails.logger.info("[NotifyUnnotifiedMovesWorker] Creating MoveRequested event for move #{move.reference}")
        create_requested_event(move)
        Rails.logger.info("[NotifyUnnotifiedMovesWorker] Created MoveRequested event for move #{move.reference}")
      end

      Rails.logger.info("[NotifyUnnotifiedMovesWorker] Creating move_create Notification for move #{move.reference}")
      Notifier.prepare_notifications(topic: move, action_name: 'create')
      Rails.logger.info("[NotifyUnnotifiedMovesWorker] Created move_create Notification for move #{move.reference}")
    end
  end

private

  def create_requested_event(move)
    GenericEvent::MoveRequested.create!(
      eventable: move,
      occurred_at: move.created_at,
      recorded_at: Time.zone.now,
      notes: 'Automatically generated event',
      details: {},
    )
  end
end
