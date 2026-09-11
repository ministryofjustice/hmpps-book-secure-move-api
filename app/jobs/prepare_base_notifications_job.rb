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
    # only cross-supplier suppliers get `cross_supplier_add` or `cross_supplier_remove` notifications
    case action_name
    when 'cross_supplier_add'
      return Subscription.kept.enabled.where(supplier: move.to_location&.suppliers || [])
    when 'cross_supplier_remove'
      notified_sub_ids = Notification.where(topic: move, event_type: 'cross_supplier_move_add').pluck(:subscription_id)
      return Subscription.kept.enabled.where(id: notified_sub_ids)
    end

    suppliers = [move.supplier || move.suppliers].flatten

    if move.cross_supplier?
      suppliers += move.to_location&.suppliers || []
    end

    suppliers = suppliers.uniq.filter do |supplier|
      only_supplier_id.nil? || only_supplier_id == supplier.id
    end

    Subscription.kept.enabled.where(supplier: suppliers)
  end

  def build_and_send_notifications(subscription, type_id, topic, action_name, queue_as)
    # Row-level lock on the subscription to reliably prevent race conditions when creating notifications
    # Race conditions are present due to cross_supplier notification checks that rely on _add and _remove records being created
    notification = subscription.with_lock do
      type = event_type(action_name, topic, type_id, subscription)

      next if type.starts_with?('cross_supplier_') && !notifiable_cross_supplier?(subscription, topic)

      create_notification(subscription, type_id, topic, type)
    end

    return if notification.nil?

    notify_job(type_id).perform_later(notification_id: notification.id, queue_as:)
  end

  def notifiable_cross_supplier?(subscription, topic)
    # Move's assigned supplier should never get cross-supplier notifications
    return false if subscription.supplier == topic.supplier

    enabled_suppliers = ENV.fetch('FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS', '').split(',')
    enabled_suppliers.include?(subscription.supplier.key)
  end

  def create_notification(subscription, type_id, topic, type)
    subscription.notifications.create!(
      notification_type_id: type_id,
      topic:,
      event_type: type,
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

  CROSS_SUPPLIER_EQUIVALENT = {
    'update_move' => 'cross_supplier_move_update',
    'update_move_status' => 'cross_supplier_move_update_status',
  }.freeze

  def event_type(action_name, topic, type_id, subscription)
    action = {
      'create' => 'create_move',
      'update' => 'update_move',
      'update_status' => 'update_move_status',
      'destroy' => 'destroy_move',
      'cross_supplier_add' => 'cross_supplier_move_add',
      'cross_supplier_remove' => 'cross_supplier_move_remove',
    }.fetch(action_name, action_name)

    is_move = topic.is_a?(Move)

    is_sending_move_action_to_cross_supplier = is_move &&
      topic.supplier != subscription.supplier

    is_sending_move_action_to_subscription_supplier = is_move &&
      topic.supplier == subscription.supplier

    subscription_supplier_is_in_from_location_suppliers = is_move &&
      topic.from_location.suppliers.include?(subscription.supplier)

    if is_sending_move_action_to_subscription_supplier

      # make sure we send a create_move notification if we haven't sent one yet
      if action == 'update_move_status'
        create_move_exists = Notification.kept.exists?(subscription: subscription, topic: topic, event_type: 'create_move', notification_type_id: type_id)
        action = 'create_move' if !create_move_exists && !topic.cancelled?
      end

    elsif is_sending_move_action_to_cross_supplier

      # send create notification as `cross_supplier_move_add` if we are notifying a cross-supplier supplier
      if action == 'create_move' &&
          !subscription_supplier_is_in_from_location_suppliers
        action = 'cross_supplier_move_add'
      end

      # make sure we send a cross_supplier_move_add notification if we haven't sent one yet
      if %w[update_move update_move_status].include?(action) &&
          !subscription_supplier_is_in_from_location_suppliers
        active_move_add = active_cross_supplier_move_add?(subscription, topic, type_id)
        action = !active_move_add ? 'cross_supplier_move_add' : CROSS_SUPPLIER_EQUIVALENT[action]
      end

    end

    action
  end

  # A move can be added, removed and re-added as cross-supplier, so an add is
  # only still active if it has not been matched by a removal
  # This simply checks counts of adds and removes to determine if a cross-supplier move_add is still active
  def active_cross_supplier_move_add?(subscription, topic, type_id)
    counts = Notification.kept
                         .where(subscription:, topic:, notification_type_id: type_id)
                         .where(event_type: %w[cross_supplier_move_add cross_supplier_move_remove])
                         .group(:event_type)
                         .count

    counts['cross_supplier_move_add'].to_i > counts['cross_supplier_move_remove'].to_i
  end

  def notify_job(type_id)
    {
      NotificationType::WEBHOOK => NotifyWebhookJob,
      NotificationType::EMAIL => NotifyEmailJob,
    }[type_id]
  end
end
