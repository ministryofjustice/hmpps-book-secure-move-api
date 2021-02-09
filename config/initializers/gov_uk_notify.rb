# We only send emails if GOVUK_NOTIFY_ENABLED is true - and should generally only be enabled on the Sidekiq pod
# Note that the app pod and metrics containers should not send GovUk Notify emails
if ENV['GOVUK_NOTIFY_ENABLED'] =~ /true/i
  if ENV['GOVUK_NOTIFY_API_KEY'].blank?
    Rails.logger.warn('GOVUK_NOTIFY_API_KEY env var is not set; emails cannot be sent')
    Raven.capture_message('GOVUK_NOTIFY_API_KEY env var is not set; emails cannot be sent', { level: 'warning' })
  end

  # TODO: Remove use of GOVUK_NOTIFY_TEMPLATE_ID - change to GOVUK_NOTIFY_MOVE_TEMPLATE_ID & GOVUK_NOTIFY_PER_TEMPLATE_ID
  if ENV['GOVUK_NOTIFY_TEMPLATE_ID'].blank?
    Rails.logger.warn('GOVUK_NOTIFY_TEMPLATE_ID env var is not set; emails cannot be sent')
    Raven.capture_message('GOVUK_NOTIFY_TEMPLATE_ID env var is not set; emails cannot be sent', { level: 'warning' })
  end

  ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery, api_key: ENV.fetch('GOVUK_NOTIFY_API_KEY', nil)
end
