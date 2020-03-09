# frozen_string_literal: true

# This job is responsible for sending the notification to the supplier's webhook endpoint
class NotifyWebhookJob < ApplicationJob
  queue_as :notifications

  def perform(notification_id:)
    notification = Notification.webhooks.kept.includes(:subscription).find(notification_id)
    return unless notification.subscription.enabled?

    data = ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json
    hmac = Encryptor.hmac(notification.subscription.secret, data)
    response = nil

    begin
      response = client.post(notification.subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification_id)
      if response.success?
        notification.delivered_at = DateTime.now
        # TODO: in the future, consider suggesting that the webhook endpoint could return a UUID in the response, which we could store in notification.response_id ?
      else
        Rails.logger.error("[NotifyWebhookJob] non-success status received from #{notification.subscription.callback_url} (#{response.status})")
      end
    rescue Faraday::ClientError => e
      Rails.logger.error("[NotifyWebhookJob] failed to notify #{notification.subscription.callback_url}: #{e.inspect}")
    end

    notification.update(delivery_attempts: notification.delivery_attempts.succ,
                        delivery_attempted_at: DateTime.now)

    # It is necessary to raise an error in order for Sidekiq to retry the notification
    raise 'Webhook notification failed' unless response&.success?
  end

private

  def client
    Faraday.new(headers: { 'Content-Type': 'application/vnd.api+json', 'User-Agent': 'pecs-webhooks/v1' })
  end
end
