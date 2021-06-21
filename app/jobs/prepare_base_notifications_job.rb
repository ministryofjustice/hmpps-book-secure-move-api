# frozen_string_literal: true

# This job is responsible for preparing a set of notify jobs to run
class PrepareBaseNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, queue_as:, send_webhooks: true, send_emails: true, only_supplier_id: nil)
    topic = find_topic(topic_id)
    move = associated_move(topic)

    # if the move has a specified supplier, use it; otherwise use the move.suppliers delegate based on from_location
    [move.supplier || move.suppliers].flatten.each do |supplier|
      next unless only_supplier_id.nil? || only_supplier_id == supplier.id

      supplier.subscriptions.kept.each do |subscription|
        next unless subscription.enabled?

        # NB: always notify the webhook (if defined) on any change, even for back-dated historic moves
        # feature flag certain webhook messages: disable if there is an envvar DISABLE_WEBHOOK_<ACTIONNAME>_<SUPPLIER>=="TRUE"
        if send_webhooks && subscription.callback_url.present? && should_webhook?(move) && (ENV.fetch("DISABLE_WEBHOOK_#{action_name.upcase}_#{supplier.key.upcase}", 'FALSE') !~ /TRUE/i)
          NotifyWebhookJob.perform_later(
            notification_id: build_notification(subscription, NotificationType::WEBHOOK, topic, action_name).id,
            queue_as: queue_as, # send webhook with same priority as move
          )
        end

        # NB: only email in certain conditions (should_email?)
        next unless send_emails && subscription.email_address.present? && should_email?(move)

        NotifyEmailJob.perform_later(
          notification_id: build_notification(subscription, NotificationType::EMAIL, topic, action_name).id,
          queue_as: queue_as, # send email with same priority as move
        )
      end
    end
  end

private

  def find_topic(topic_id)
    raise NotImplementedError
  end

  def associated_move(topic)
    raise NotImplementedError
  end

  def build_notification(subscription, type_id, topic, action_name)
    subscription.notifications.create!(
      notification_type_id: type_id,
      topic: topic,
      event_type: event_type(action_name),
    )
  end

  def should_webhook?(move)
    # NB: we should not send webhooks for :proposed moves - these are completely internal to Book a Secure Move
    Move::MOVE_STATUS_PROPOSED != move.status
  end

  def should_email?(move)
    # NB: only email for:
    #   * move.status must be :requested, :booked, :in_transit or :cancelled (not :proposed or :completed), AND
    #   * move must be current (i.e. move.date is not in the past OR move.to_date is not in the past)
    [Move::MOVE_STATUS_REQUESTED, Move::MOVE_STATUS_BOOKED, Move::MOVE_STATUS_IN_TRANSIT, Move::MOVE_STATUS_CANCELLED].include?(move.status) && move.current?
  end

  def event_type(action_name)
    {
      'create' => 'create_move',
      'update' => 'update_move',
      'update_status' => 'update_move_status',
      'destroy' => 'destroy_move',
    }[action_name] || action_name
  end
end
