if ENV['GOVUK_NOTIFY_API_KEY'].blank?
  Rails.logger.warn('GOVUK_NOTIFY_API_KEY env var is not set; emails cannot be sent')
  Raven.capture_message('GOVUK_NOTIFY_API_KEY env var is not set; emails cannot be sent', { level: 'warning' })
end

if ENV['GOVUK_NOTIFY_TEMPLATE_ID'].blank?
  Rails.logger.warn('GOVUK_NOTIFY_TEMPLATE_ID env var is not set; emails cannot be sent')
  Raven.capture_message('GOVUK_NOTIFY_TEMPLATE_ID env var is not set; emails cannot be sent', { level: 'warning' })
end

# NB: for an unset APIKEY the library prefers empty string rather than nil
ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery, api_key: ENV.fetch('GOVUK_NOTIFY_API_KEY', nil)
