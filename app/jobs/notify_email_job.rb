# frozen_string_literal: true

class NotifyEmailJob < NotifyJob
  include QueueDeterminer

  def notification_scope
    Notification.emails
  end

  def perform_notification(notification)
    response = notification.mailer.notify(notification).deliver_now!
    raise 'GOV.UK Notify Response is missing' if response.govuk_notify_response.blank?

    response.govuk_notify_response.id
  end
end
