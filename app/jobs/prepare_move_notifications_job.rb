# frozen_string_literal: true

class PrepareMoveNotificationsJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id:, action_name:)
    move = Move.find(topic_id)

    move.suppliers.each do |supplier|
      supplier.subscriptions.kept.each do |subscription|
        next unless subscription.enabled?

        # always notify the webhook (if defined) on any change
        if subscription.callback_url.present?
          NotifyWebhookJob.perform_later(
            build_notification_id(subscription, NotificationType::WEBHOOK, move, "#{action_name}_move"),
          )
        end

        # only notify by email on creation and cancellation
        if subscription.email_addresses.present? && (action_name == 'create')
          NotifyEmailJob.perform_later(
            build_notification_id(subscription, NotificationType::EMAIL, move, "#{action_name}_move"),
          )
        end
      end
    end
  end

private

  def build_notification_id(subscription, type_id, topic, event_type)
    { notification_id:
          subscription.notifications.create!(
            notification_type_id: type_id,
            topic: topic,
            event_type: event_type,
          ).id }
  end
end
