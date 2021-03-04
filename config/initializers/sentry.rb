return unless ENV['SENTRY_DSN'].present?

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']


  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    event.request.data = filter.filter(event.request.data)
    event
  end

  # This is the default value for this option, putting here for visiblity
  # This will remove the request body from the information sent to sentry
  config.send_default_pii = false

  # Half of all requests will be used in perfomace sampling. 
  config.traces_sample_rate = 0.5
end
