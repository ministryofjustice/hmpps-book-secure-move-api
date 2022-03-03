# frozen_string_literal: true

class NotifyWebhookJob < ApplicationJob
  include QueueDeterminer

  def perform(notification_id:, **_)
    notification = Notification.webhooks.kept.includes(:subscription).find(notification_id)

    subscription = notification.subscription
    return unless subscription.enabled?

    return if notification.delivered_at.present?

    begin
      perform_request(notification, subscription)
    rescue StandardError => e
      update_notification(notification, success: false)
      record_failure(subscription, notification, e)
      raise RetryJobError, e
    else
      update_notification(notification, success: true)
    end
  end

private

  def perform_request(notification, subscription)
    data = NotificationSerializer.new(notification).serializable_hash.to_json
    hmac = Encryptor.hmac(subscription.secret, data)
    client = get_client(subscription)

    response = client.post(subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification.id)

    unless response.success?
      raise NotificationFailedResponseError, "Non-success status received from #{subscription.callback_url}.\nStatus: #{response.status}, Reason: #{response.reason_phrase}, Response body: '#{response.body}'"
    end
  rescue Faraday::ConnectionFailed
    raise NotificationFailedResponseError, "Connection failed to #{subscription.callback_url}."
  rescue Faraday::TimeoutError
    raise NotificationFailedResponseError, "Timeout received from #{subscription.callback_url}."
  end

  FARADAY_OPTIONS = {
    headers: { 'Content-Type': 'application/vnd.api+json', 'User-Agent': 'pecs-webhooks/v1' },
    request: { timeout: ENV.fetch('WEBHOOK_TIMEOUT', 10).to_i },
  }.freeze

  def get_client(subscription)
    Faraday.new(FARADAY_OPTIONS).tap do |client|
      if subscription.username.present? && subscription.password.present?
        client.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{subscription.username}:#{subscription.password}")}"
      end
    end
  end

  def update_notification(notification, success:)
    notification.update!(
      delivered_at: success ? Time.zone.now : nil,
      delivery_attempts: notification.delivery_attempts.succ,
      delivery_attempted_at: Time.zone.now,
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

class NotificationFailedResponseError < StandardError; end
