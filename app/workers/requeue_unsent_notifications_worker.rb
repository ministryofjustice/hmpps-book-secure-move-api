# frozen_string_literal: true

class RequeueUnsentNotificationsWorker
  include Sidekiq::Worker

  NOTIFY_JOBS = {
    NotificationType::EMAIL => NotifyEmailJob,
    NotificationType::WEBHOOK => NotifyWebhookJob,
  }.freeze

  def perform
    Notification.where(
      delivery_attempts: 0,
      updated_at: 1.day.ago..1.hour.ago,
      notification_type_id: [NotificationType::EMAIL, NotificationType::WEBHOOK],
    ).each do |notification|
      NOTIFY_JOBS[notification.notification_type_id]
        .perform_later(notification_id: notification.id, queue_as: :notifications_high)
    end
  end
end
