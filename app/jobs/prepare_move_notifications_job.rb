# frozen_string_literal: true

# This job is responsible for preparing a set of notify jobs to run
class PrepareMoveNotificationsJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id:, action_name:)
    move = Move.find(topic_id)

    move.suppliers.each do |supplier|
      supplier.subscriptions.kept.each do |subscription|
        next unless subscription.enabled?

        # NB: always notify the webhook (if defined) on any change, even for back-dated historic moves
        if subscription.callback_url.present?
          NotifyWebhookJob.perform_later(
            build_notification_id(subscription, NotificationType::WEBHOOK, move, action_name),
          )
        end

        # NB: only email in certain conditions (should_email?)
        if subscription.email_address.present? && should_email?(move)
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
            event_type: event_type(action_name),
          ).id }
  end

  def should_email?(move)
    # NB: only email for:
    #   * move.status must be Requested or Cancelled (not Proposed or Completed) moves, AND
    #   * move must be current (i.e. move.date is not in the past OR move.to_date is not in the past)
    [Move::MOVE_STATUS_REQUESTED, Move::MOVE_STATUS_CANCELLED].include?(move.status) && move.current?
  end

  def event_type(action_name)
    {
        'create' => 'create_move',
        'update' => 'update_move',
        'update_status' => 'update_move_status',
        'destroy' => 'destroy_move',
    }[action_name]
  end
end
