# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version')

gem 'active_model_serializers', '~> 0.10.0'

# don't enable this in dev/test - the insights envs are staging/preprod/prod
group :production, :staging, :preprod do
  # usage docs for application_insights gem at
  # https://github.com/microsoft/ApplicationInsights-Ruby
  # Gem to add insights automatically to a Rack application
  # enhanced to support a RequestTracker with an ignore list
  gem 'appinsights', github: 'ministryofjustice/appinsights'
end
gem 'aws-sdk-s3', require: false
gem 'bcrypt', require: false
gem 'bootsnap', '>= 1.1.0', require: false
gem 'cancancan'
# explicit soft-deletes
gem 'discard'
gem 'doorkeeper'
gem 'elastic-apm'
gem 'faraday'
gem 'finite_machine'
gem 'govuk_notify_rails', '~> 2.1.2'
# static page serving for extra API documentation
gem 'json-schema'
gem 'kaminari'
gem 'net-http-persistent'
gem 'nokogiri', '>= 1.10.4'
gem 'notifications-ruby-client', '~> 5.1.2'
gem 'oauth2'
gem 'pager_api'
gem 'paper_trail'
gem 'pg', '~> 1.0.0'
gem 'prometheus_exporter'
gem 'puma', '~> 3.12.6'
gem 'rails', '~> 6.0.3'
gem 'redis', '~> 4.2', '>= 4.2.1'
gem 'routing-filter', '~> 0.6.3'
gem 'sentry-raven'
gem 'sidekiq'
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
  gem 'simplecov', require: false
end
