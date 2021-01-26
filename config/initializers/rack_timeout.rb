# NB: this middleware should never be mounted on production or pre-production
if Rails.env.development? || ENV.fetch('HOSTNAME', 'UNKNOWN') =~ /(\-(dev|staging|uat)\-)/i
  require 'rack/timeout/base'

  # Insert timeout middleware with a short timeout to catch downstream timeouts; this can be increased
  # at a later date once we get a better idea of which requests are problematic.
  Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 9
end
