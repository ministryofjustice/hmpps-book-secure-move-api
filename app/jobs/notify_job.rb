# frozen_string_literal: true

class NotifyJob < ApplicationJob
  queue_as :webhooks

  def perform(notification_id:)
    notification = Notification.kept.includes(:subscription).find(notification_id)

    return unless notification.subscription.enabled?

    data = ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json
    hmac = Encryptor.hmac(notification.subscription.secret, data)

    response = client.post(notification.subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification_id)

    notification.delivered_at = DateTime.now if response.success?

    notification.update(delivery_attempts: notification.delivery_attempts.succ,
                        delivery_attempted_at: DateTime.now)
  end

private

  def client
    Faraday.new(headers: { 'Content-Type': 'application/vnd.api+json', 'User-Agent': 'pecs-webhooks/v1' })
  end
end
