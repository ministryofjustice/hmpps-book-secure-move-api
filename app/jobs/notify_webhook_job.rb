# frozen_string_literal: true

# This job is responsible for sending the notification to the supplier's webhook endpoint
class NotifyWebhookJob < ApplicationJob
  include QueueDeterminer

  def perform(notification_id:, **_)
    notification = Notification.webhooks.kept.includes(:subscription).find(notification_id)
    subscription = notification.subscription
    return unless subscription.enabled?

    # just return if the notification has been already delivered
    return if notification.delivered_at.present?

    begin
      data = NotificationSerializer.new(notification).serializable_hash.to_json
      hmac = Encryptor.hmac(subscription.secret, data)
      client = get_client(subscription)
      response = client.post(subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification_id)

      unless response.success?
        raise "non-success status received from #{subscription.callback_url}. Status: #{response.status}, Reason: #{response.reason_phrase}, Response body: '#{response.body}'"
      end

      notification.update(
        delivered_at: Time.zone.now,
        delivery_attempts: notification.delivery_attempts.succ,
        delivery_attempted_at: Time.zone.now,
      )
      # TODO: in the future, consider suggesting that the webhook endpoint could return a UUID in the response, which we could store in notification.response_id ?
    rescue StandardError => e
      notification.update(
        delivery_attempts: notification.delivery_attempts.succ,
        delivery_attempted_at: Time.zone.now,
      )
      Raven.capture_exception(e)
      raise e # re-raise the error to force the notification to be retried by sidekiq later
    end
  end

private

  def get_client(subscription)
    client = Faraday.new(headers: { 'Content-Type': 'application/vnd.api+json', 'User-Agent': 'pecs-webhooks/v1' })
    if subscription.username.present? && subscription.password.present?
      client.headers['Authorization'] = "Basic #{Base64.strict_encode64(subscription.username + ':' + subscription.password)}"
    end
    client
  end
end
