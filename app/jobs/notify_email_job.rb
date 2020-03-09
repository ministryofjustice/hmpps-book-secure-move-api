# frozen_string_literal: true

# This job is responsible for sending the notification to the Gov.UK Notify service.
# It runs as a retryable job to handle the case where the Gov.UK service is temporarily offline.
class NotifyEmailJob < ApplicationJob
  queue_as :notifications

  def perform(notification_id:)
    notification = Notification.emails.kept.includes(:subscription).find(notification_id)
    return unless notification.subscription.enabled?

    if ENV['GOVUK_NOTIFY_API_KEY'].blank?
      Rails.logger.error('[NotifyEmailJob] please set the GOVUK_NOTIFY_API_KEY env variable')
      return # no point retrying later
    end

    if ENV['GOVUK_NOTIFY_TEMPLATE_ID'].blank?
      Rails.logger.error('[NotifyEmailJob] please set the GOVUK_NOTIFY_TEMPLATE_ID env variable')
      return # no point retrying later
    end

    response = nil
    begin
      response = MoveMailer.notify(notification).deliver!

      if response.govuk_notify_response.present?
        notification.delivered_at = DateTime.now
        notification.response_id = response.govuk_notify_response.id
      else
        Rails.logger.error('[NotifyEmailJob] no response received from service')
      end
    rescue StandardError => e
      Rails.logger.error("[NotifyEmailJob] failed to deliver to service: (#{e.message})")
    end

    notification.update(delivery_attempts: notification.delivery_attempts.succ,
                        delivery_attempted_at: DateTime.now)

    # It is necessary to raise an error in order for Sidekiq to retry the notification
    raise 'Notification failed' unless response&.govuk_notify_response&.present?
  end
end
