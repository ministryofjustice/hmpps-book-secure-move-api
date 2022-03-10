# frozen_string_literal: true

class NotifyWebhookJob < NotifyJob
  include QueueDeterminer

  def notification_scope
    Notification.webhooks
  end

  def perform_notification(notification)
    subscription = notification.subscription

    data = NotificationSerializer.new(notification).serializable_hash.to_json
    hmac = Encryptor.hmac(subscription.secret, data)
    client = get_client(subscription)

    response = client.post(subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification.id)

    unless response.success?
      raise NotificationFailedResponseError, "Non-success status received from #{subscription.callback_url}.\nStatus: #{response.status}, Reason: #{response.reason_phrase}, Response body: '#{response.body}'"
    end

    nil
  rescue Faraday::ConnectionFailed
    raise NotificationFailedResponseError, "Connection failed to #{subscription.callback_url}."
  rescue Faraday::TimeoutError
    raise NotificationFailedResponseError, "Timeout received from #{subscription.callback_url}."
  end

private

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
end

class NotificationFailedResponseError < StandardError; end
