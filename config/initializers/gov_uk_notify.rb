# We only send emails if GOVUK_NOTIFY_ENABLED is true - and should generally only be enabled on the Sidekiq pod
# Note that the app pod and metrics containers should not send GovUk Notify emails
if ENV['GOVUK_NOTIFY_ENABLED'] =~ /true/i
  %w[GOVUK_NOTIFY_API_KEY GOVUK_NOTIFY_MOVE_TEMPLATE_ID GOVUK_NOTIFY_MOVE_REJECT_TEMPLATE_ID GOVUK_NOTIFY_PER_TEMPLATE_ID].each do |name|
    if ENV[name].blank?
      Rails.logger.warn("#{name} env var is not set; emails cannot be sent")
      Sentry.capture_message("#{name} env var is not set; emails cannot be sent", level: 'warning')
    end
  end

  ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery, api_key: ENV.fetch('GOVUK_NOTIFY_API_KEY', nil)
end
