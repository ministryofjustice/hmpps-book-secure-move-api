# frozen_string_literal: true

class NotifyUnnotifiedMovesWorker
  include Sidekiq::Worker

  def perform
    Move.where(date: Time.zone.today..Time.zone.tomorrow)
        .where.not(status: %w[proposed cancelled])
        .select { |m| m.notifications.empty? }
        .each do |move|
      was_initially_proposed = move.versions.count > 1 && move.versions[1].reify.status == 'proposed'
      initial_event_class = "GenericEvent::#{was_initially_proposed ? 'MoveProposed' : 'MoveRequested'}"
      notification_type = was_initially_proposed ? 'update_status' : 'create'

      unless move.generic_events.pluck(:type).include?(initial_event_class)
        Rails.logger.info("[NotifyUnnotifiedMovesWorker] Creating #{initial_event_class} event for move #{move.reference}")
        create_event(move, initial_event_class.constantize)
        Rails.logger.info("[NotifyUnnotifiedMovesWorker] Created #{initial_event_class} event for move #{move.reference}")
      end

      Rails.logger.info("[NotifyUnnotifiedMovesWorker] Creating #{notification_type} notifications for move #{move.reference}")
      Notifier.prepare_notifications(topic: move, action_name: notification_type)
      Rails.logger.info("[NotifyUnnotifiedMovesWorker] Created #{notification_type} notifications for move #{move.reference}")
    end
  end

private

  def create_event(move, event_class)
    event_class.create!(
      eventable: move,
      occurred_at: move.created_at,
      recorded_at: Time.zone.now,
      notes: 'Automatically generated event',
      details: {},
    )
  end
end
