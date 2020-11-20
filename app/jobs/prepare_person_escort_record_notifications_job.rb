# frozen_string_literal: true

class PreparePersonEscortRecordNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, **_)
    person_escort_record = PersonEscortRecord.find(topic_id)
    return unless (move = person_escort_record.move)

    [move.supplier || move.suppliers].flatten.each do |supplier|
      supplier.subscriptions.kept.each do |subscription|
        next unless subscription.enabled? && subscription.callback_url.present?

        NotifyWebhookJob.perform_later(
          notification_id: build_notification(subscription, NotificationType::WEBHOOK, move).id,
          queue_as: move_queue_priority(move),
        )
      end
    end
  end

private

  def build_notification(subscription, type_id, topic)
    subscription.notifications.create!(
      notification_type_id: type_id,
      topic: topic,
      event_type: 'confirm_person_escort_record',
    )
  end
end
