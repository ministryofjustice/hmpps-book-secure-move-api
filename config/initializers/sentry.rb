return unless ENV['SENTRY_DSN'].present?

EXCLUDE_PATHS = %w[/ping /ping.json /health /health.json].freeze

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    # filter the request data if there is an associated request (manually raised events won't have a request)
    event.request.data = filter.filter(event.request.data) if event.request&.data.present?
    event
  end

  # This is the default value for this option, putting here for visiblity
  # This will remove the request body from the information sent to sentry
  config.send_default_pii = false

  # Don't log RetryJobError exceptions in Sentry as they will have already been logged as part of the failed job
  config.excluded_exceptions += ['RetryJobError']

  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]
    transaction_name = transaction_context[:name]

    transaction_name.in?(EXCLUDE_PATHS) ? 0.0 : 0.5
  end
end
