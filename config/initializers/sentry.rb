return unless ENV['SENTRY_DSN'].present?

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

  # Half of all requests will be used in performance sampling.
  # Currently the MoJ plan does not allow this. Turn on when
  # plan has been updated in July 2021
  # config.traces_sample_rate = 0.5
end
