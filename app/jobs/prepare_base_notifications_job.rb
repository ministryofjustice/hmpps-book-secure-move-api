# frozen_string_literal: true

class PrepareBaseNotificationsJob < ApplicationJob
  include QueueDeterminer

  def perform(topic_id:, action_name:, queue_as:, send_webhooks: true, send_emails: true, only_supplier_id: nil)
    topic = find_topic(topic_id)
    move = associated_move(topic)

    subscriptions(move, action_name:, only_supplier_id:).find_each do |subscription|
      if send_webhooks && subscription.callback_url.present? && should_webhook?(subscription, move, action_name)
        build_and_send_notifications(subscription, NotificationType::WEBHOOK, topic, action_name, queue_as)
      end

      if send_emails && subscription.email_address.present? && should_email?(move)
        build_and_send_notifications(subscription, NotificationType::EMAIL, topic, action_name, queue_as)
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

  def subscriptions(move, action_name:, only_supplier_id: nil)
    # only cross-deck suppliers get `notify` or `disregard` notifications
    case action_name
    when 'notify'
      return Subscription.kept.enabled.where(supplier: move.to_location&.suppliers || [])
    when 'disregard'
      notified_sub_ids = Notification.where(topic: move, event_type: 'notify_move').pluck(:subscription_id)
      return Subscription.kept.enabled.where(id: notified_sub_ids)
    end

    suppliers = [move.supplier || move.suppliers].flatten

    if move.cross_deck?
      suppliers += move.to_location&.suppliers || []
    end

    suppliers = suppliers.uniq.filter do |supplier|
      only_supplier_id.nil? || only_supplier_id == supplier.id
    end

    Subscription.kept.enabled.where(supplier: suppliers)
  end

  def build_and_send_notifications(subscription, type_id, topic, action_name, queue_as)
    notification = subscription.notifications.create!(
      notification_type_id: type_id,
      topic:,
      event_type: event_type(action_name, topic, type_id, subscription),
    )
    notify_job(type_id).perform_later(notification_id: notification.id, queue_as:)
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

  def event_type(action_name, topic, type_id, subscription)
    action = {
      'create' => 'create_move',
      'update' => 'update_move',
      'update_status' => 'update_move_status',
      'destroy' => 'destroy_move',
      'notify' => 'notify_move',
      'disregard' => 'disregard_move',
    }.fetch(action_name, action_name)

    # make sure we send a create_move notification if we haven't sent one yet
    if action == 'update_move_status'
      create_notification = topic.notifications.find_by(event_type: 'create_move', notification_type_id: type_id)
      action = 'create_move' if create_notification.nil? && !topic.cancelled?
    end

    # send create notification as `notify_move` if we are notifying a cross-deck supplier
    if action == 'create_move' && !topic.from_location.suppliers.include?(subscription.supplier)
      action = 'notify_move'
    end

    # make sure we send a notify_move notification if we haven't sent one yet for a cross-deck supplier
    if action == 'update_move' && !topic.from_location.suppliers.include?(subscription.supplier)
      notify_notification = topic.notifications.find_by(event_type: 'notify_move', notification_type_id: type_id)
      action = 'notify_move' if notify_notification.nil? && !topic.cancelled?
    end

    action
  end

  def notify_job(type_id)
    {
      NotificationType::WEBHOOK => NotifyWebhookJob,
      NotificationType::EMAIL => NotifyEmailJob,
    }[type_id]
  end
end
