class NotifyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    notification = Notification.find(args[:notification_id])
    request = client.post(url: notification.subscription.callback_url,
                          body: notification.data)

    if request.status == 202
      notification.update_attribute(delivered_at: DataTime.now)
    else
      nortification.update_attribute(delivery_attempts: notification.delivery_attempts.succ,
                                     delivery_attempted_at: DateTime.now)
    end
  end

private

  def client
    Faraday.new(headers: { 'Content-Type': 'application/json' })
  end
end
