# frozen_string_literal: true

# This job is responsible for sending the notification to the Gov.UK Notify service.
# It runs as a retryable job to handle the case where the Gov.UK service is temporarily offline.
class NotifyEmailJob < ApplicationJob
  include QueueDeterminer

  def perform(notification_id:, **_)
    notification = Notification.emails.kept.includes(:subscription).find(notification_id)
    return unless notification.subscription.enabled?

    # just return if the notification has been already delivered
    return if notification.delivered_at.present?

    begin
      # NB: deliver_now! will raise an exception unless the email is delivered to gov.uk Notify
      response = notification.mailer.notify(notification).deliver_now!
      raise('govuk_notify_response is missing') if response.govuk_notify_response.blank?

      notification.update(
        delivered_at: Time.zone.now,
        response_id: response.govuk_notify_response.id,
        delivery_attempts: notification.delivery_attempts.succ,
        delivery_attempted_at: Time.zone.now,
      )
    rescue StandardError => e
      notification.update(
        delivery_attempts: notification.delivery_attempts.succ,
        delivery_attempted_at: Time.zone.now,
      )
      Sentry.capture_exception(e)
      raise e # re-raise the error to force the notification to be retried by sidekiq later
    end
  end
end
