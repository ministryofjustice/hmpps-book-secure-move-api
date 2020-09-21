return if ENV['SENTRY_DSN'].blank?

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end

Raven.tags_context(
  'url' => ENV['SERVER_FQDN'],
)
