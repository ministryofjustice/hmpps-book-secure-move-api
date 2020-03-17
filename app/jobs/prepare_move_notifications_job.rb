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

        if subscription.email_address.present? && should_email?(move, action_name)
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
            event_type: event_type(action_name, topic),
          ).id }
  end

  def should_email?(move, action_name)
    # NB: only notify by email on move requested and move cancellation
    [Move::MOVE_STATUS_REQUESTED, Move::MOVE_STATUS_CANCELLED].include?(move.status) && %w(create update_status).include?(action_name)
  end

  def event_type(action_name, topic)
    # NB: this transforms "update" --> "update_move" and "update_status" --> "update_move_status"
    action_name.split('_').insert(1, topic.class.to_s.downcase).join('_')
  end
end
