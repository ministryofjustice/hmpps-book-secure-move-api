# frozen_string_literal: true

# check for environment variable so that we can run production rake task in Dockerfile
# otherwise we try to load the metrics outside of the actual app itself
if ['on', 'true'].include? ENV['PROMETHEUS_METRICS']
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/instrumentation'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
  PrometheusExporter::Instrumentation::Process.start(type: 'master')
end
