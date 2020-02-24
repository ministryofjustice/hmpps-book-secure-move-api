# frozen_string_literal: true

class NotifyJob < ApplicationJob
  queue_as :webhooks

  def perform(notification_id:)
    notification = Notification.kept.includes(:subscription).find(notification_id)
    return unless notification.subscription.enabled?

    data = ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json
    hmac = Encryptor.hmac(notification.subscription.secret, data)
    success = false # assume failure

    begin
      response = client.post(notification.subscription.callback_url, data, 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification_id)
      if response.success?
        notification.delivered_at = DateTime.now
        success = true
      else
        puts "Error: non-success status received from #{notification.subscription.callback_url} (#{response.status})"
      end
    rescue Faraday::ClientError => e
      puts "Error notifying #{notification.subscription.callback_url}: #{e.inspect}"
    end

    notification.update(delivery_attempts: notification.delivery_attempts.succ,
                        delivery_attempted_at: DateTime.now)

    # It is necessary to raise an error in order for Sidekiq to retry the notification
    raise 'Notification failed' unless success
  end

private

  def client
    Faraday.new(headers: { 'Content-Type': 'application/vnd.api+json', 'User-Agent': 'pecs-webhooks/v1' })
  end
end
