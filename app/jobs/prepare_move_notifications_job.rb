# frozen_string_literal: true

# This job is responsible for preparing a set of notify jobs to run
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
            build_notification_id(subscription, NotificationType::WEBHOOK, move, action_name),
          )
        end

        # only notify by email on creation and cancellation
        # TODO: do we need to check if move.status == Move::MOVE_STATUS_REQUESTED ?
        if subscription.email_address.present? && (action_name == 'create' || (action_name == 'update' && move.status == Move::MOVE_STATUS_CANCELLED))
          NotifyEmailJob.perform_later(
            build_notification_id(subscription, NotificationType::EMAIL, move, action_name),
          )
        end
      end
    end
  end

private

  def build_notification_id(subscription, type_id, topic, action_name)
    { notification_id:
          subscription.notifications.create!(
            notification_type_id: type_id,
            topic: topic,
            event_type: "#{action_name}_#{topic.class.to_s.downcase}",
          ).id }
  end
end
