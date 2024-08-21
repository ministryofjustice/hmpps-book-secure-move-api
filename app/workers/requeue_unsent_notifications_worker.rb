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
    ).find_each do |notification|
      notify_job = NOTIFY_JOBS[notification.notification_type_id]
      notify_job.perform_later(notification_id: notification.id, queue_as: :notifications_high)

      Rails.logger.info(
        "[RequeueUnsentNotificationsWorker] #{notify_job} recreated for " \
        "Notification ID #{notification.id}",
      )
    end
  end
end
