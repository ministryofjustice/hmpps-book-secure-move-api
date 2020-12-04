# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version')

# don't enable this in dev/test - the insights envs are staging/preprod/prod
group :production do
  # usage docs for application_insights gem at
  # https://github.com/microsoft/ApplicationInsights-Ruby
  # Gem to add insights automatically to a Rack application
  # enhanced to support a RequestTracker with an ignore list
  gem 'appinsights', github: 'ministryofjustice/appinsights'
end

gem 'activerecord-import', '~> 1.0', '>= 1.0.5'
gem 'auto_strip_attributes', '~> 2.6'
gem 'aws-sdk-s3', require: false
gem 'bcrypt', require: false
gem 'bootsnap', '>= 1.1.0', require: false
gem 'cancancan'
gem 'discard'
gem 'doorkeeper'
gem 'elastic-apm'
gem 'faraday'
gem 'finite_machine'
gem 'flipper-active_record', '~> 0.19'
gem 'git', '~> 1.7'
gem 'govuk_notify_rails', '~> 2.1.2'
gem 'jsonapi-serializer', '~> 2.1'
gem 'json-schema'
gem 'kaminari'
gem 'net-http-persistent'
gem 'nokogiri', '>= 1.10.4'
gem 'notifications-ruby-client', '~> 5.1.2'
gem 'oauth2'
gem 'paper_trail'
gem 'pg', '~> 1'
gem 'prometheus_exporter'
gem 'puma', '~> 5'
gem 'rails', '~> 6.0.3'
gem 'redis', '~> 4.2', '>= 4.2.1'
gem 'routing-filter', '~> 0.6.3'
gem 'sentry-raven'
gem 'sidekiq'
gem 'uk_postcode', '~> 2'
gem 'validate_url', '~> 1.0.8'

# Swagger API documentation. We need CORS to enable the Swagger UI to make requests
# against the API without an Access-Control-Allow-Origin error.
gem 'rack-cors'
gem 'rswag-api'
gem 'rswag-ui'

# Augments Rails logging to output JSON for Fluentd/Kibana
# on Cloud Platform
gem 'lograge', '~> 0.11.2'
gem 'logstash-event', '~> 1.2'
gem 'logstash-logger', '~> 0.26.1'

group :development, :test do
  gem 'dotenv'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'github_changelog_generator'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  # This needs to be in dev/test to expose the rake task
  gem 'rswag-specs'
  gem 'timecop'
end

group :development do
  gem 'listen'
  gem 'rails-erd'
  gem 'rubocop-govuk'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'climate_control'
  gem 'rack-test', '~> 1.1.0'
  gem 'service_mock', '~> 0.9' # wrapper for Wiremock
  gem 'simplecov', require: false
end
