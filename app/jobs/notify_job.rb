# frozen_string_literal: true

class NotifyJob < ApplicationJob
  def perform(notification_id:, **_)
    notification = notification_scope.kept.includes(:subscription).find(notification_id)

    subscription = notification.subscription
    return unless subscription.enabled?

    return if notification.delivered_at.present?

    begin
      response_id = perform_notification(notification)
    rescue StandardError => e
      update_notification(notification, success: false)
      record_failure(subscription, notification, e)
      raise RetryJobError, e
    else
      update_notification(notification, success: true, response_id: response_id)
    end
  end

  def notification_scope
    raise NotImplementedError
  end

  def perform_notification(notification)
    raise NotImplementedError
  end

private

  def update_notification(notification, success:, response_id: nil)
    notification.update!(
      delivered_at: success ? Time.zone.now : nil,
      delivery_attempts: notification.delivery_attempts.succ,
      delivery_attempted_at: Time.zone.now,
      response_id: response_id,
    )
  end

  def record_failure(subscription, notification, exception)
    Sentry.with_scope do |scope|
      scope.set_tags(supplier: subscription.supplier.key)
      scope.set_tags(move: notification.topic.reference) if notification.topic.is_a?(Move)
      scope.set_level(:warning) if exception.is_a?(NotificationFailedResponseError)
      Sentry.capture_exception(exception)
    end
  end
end
