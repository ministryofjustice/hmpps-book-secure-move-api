# frozen_string_literal: true

class PrepareBaseNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, queue_as:, send_webhooks: true, send_emails: true, only_supplier_id: nil)
    topic = find_topic(topic_id)
    move = associated_move(topic)

    subscriptions(move, only_supplier_id: only_supplier_id).find_each do |subscription|
      if send_webhooks && subscription.callback_url.present? && should_webhook?(subscription, move, action_name)
        notification = build_notification(subscription, NotificationType::WEBHOOK, topic, action_name)
        NotifyWebhookJob.perform_later(notification_id: notification.id, queue_as: queue_as)
      end

      if send_emails && subscription.email_address.present? && should_email?(move)
        notification = build_notification(subscription, NotificationType::EMAIL, topic, action_name)
        NotifyEmailJob.perform_later(notification_id: notification.id, queue_as: queue_as)
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

  def subscriptions(move, only_supplier_id: nil)
    suppliers = [move.supplier || move.suppliers].flatten.filter do |supplier|
      only_supplier_id.nil? || only_supplier_id == supplier.id
    end

    Subscription.kept.enabled.where(supplier: suppliers)
  end

  def build_notification(subscription, type_id, topic, action_name)
    subscription.notifications.create!(
      notification_type_id: type_id,
      topic: topic,
      event_type: event_type(action_name, topic, type_id),
    )
  end

  def should_webhook?(subscription, move, action_name)
    ENV.fetch("DISABLE_WEBHOOK_#{action_name.upcase}_#{subscription.supplier.key.upcase}", 'FALSE') !~ /TRUE/i &&
      move.status != Move::MOVE_STATUS_PROPOSED
  end

  VALID_EMAIL_STATUSES = [
    Move::MOVE_STATUS_REQUESTED,
    Move::MOVE_STATUS_BOOKED,
    Move::MOVE_STATUS_IN_TRANSIT,
    Move::MOVE_STATUS_CANCELLED,
  ].freeze

  def should_email?(move)
    move.current? && VALID_EMAIL_STATUSES.include?(move.status)
  end

  def event_type(action_name, topic, type_id)
    action = {
      'create' => 'create_move',
      'update' => 'update_move',
      'update_status' => 'update_move_status',
      'destroy' => 'destroy_move',
    }.fetch(action_name, action_name)

    return action unless action == 'update_move_status'

    create_notification = topic.notifications.find_by(event_type: 'create_move', notification_type_id: type_id)
    create_notification.nil? ? 'create_move' : 'update_move_status'
  end
end
