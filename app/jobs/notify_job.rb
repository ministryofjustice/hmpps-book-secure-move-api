class NotifyJob < ApplicationJob
  queue_as :default

  def perform(notification_id:)
    notification = Notification.find(notification_id)
    response = client.post(notification.subscription.callback_url,
                           notification.data)

    if response.success?
      notification.update(delivered_at: DateTime.now)
      puts notification.reload.delivered_at
    end

    notification.update(delivery_attempts: notification.delivery_attempts.succ,
                        delivery_attempted_at: DateTime.now)
  end

private

  def client
    Faraday.new(headers: { 'Content-Type': 'application/json' })
  end
end
