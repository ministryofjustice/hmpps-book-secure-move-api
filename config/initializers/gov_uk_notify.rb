if ENV['GOVUK_NOTIFY_API_KEY'].blank?
  Rails.logger.warn('GOVUK_NOTIFY_API_KEY env var is not set; emails cannot be sent')
end

if ENV['GOVUK_NOTIFY_TEMPLATE_ID'].blank?
  Rails.logger.warn('GOVUK_NOTIFY_TEMPLATE_ID env var is not set; emails cannot be sent')
end

ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery, api_key: ENV['GOVUK_NOTIFY_API_KEY']
