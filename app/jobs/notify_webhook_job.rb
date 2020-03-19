# frozen_string_literal: true

# This job is responsible for sending the notification to the supplier's webhook endpoint
class NotifyWebhookJob < ApplicationJob
  queue_as :notifications

  def perform(notification_id:)
    notification = Notification.webhooks.kept.includes(:subscription).find(notification_id)
    return unless notification.subscription.enabled?

    # just return if the notification has been already delivered
    return if notification.delivered_at.present?

    begin
      data = ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json
      hmac = Encryptor.hmac(notification.subscription.secret, data)
      response = client.post(notification.subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification_id)

      raise "non-success status received from #{notification.subscription.callback_url} (#{response.status})" unless response.success?

      notification.update(delivered_at: DateTime.now,
                          delivery_attempts: notification.delivery_attempts.succ,
                          delivery_attempted_at: DateTime.now)
      # TODO: in the future, consider suggesting that the webhook endpoint could return a UUID in the response, which we could store in notification.response_id ?
    rescue StandardError => e
      notification.update(delivery_attempts: notification.delivery_attempts.succ,
                          delivery_attempted_at: DateTime.now)
      Raven.capture_exception(e)
      raise e # re-raise the error to force the notification to be retried by sidekiq later
    end
  end

private

  def client
    Faraday.new(headers: { 'Content-Type': 'application/vnd.api+json', 'User-Agent': 'pecs-webhooks/v1' })
  end
end
