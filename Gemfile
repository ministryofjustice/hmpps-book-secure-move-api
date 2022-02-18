# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version')

gem 'rails', '6.1.4.1'

gem 'activerecord-import'
gem 'auto_strip_attributes'
gem 'aws-sdk-athena'
gem 'aws-sdk-s3', require: false
gem 'bcrypt', require: false
gem 'bootsnap', require: false
gem 'cancancan'
gem 'discard'
gem 'doorkeeper'
gem 'faraday'
gem 'finite_machine'
gem 'flipper-active_record'
gem 'geocoder'
gem 'git'
gem 'govuk_notify_rails'
gem 'jsonapi-serializer'
gem 'json-schema'
gem 'kaminari'
gem 'net-http-persistent'
gem 'nokogiri'
gem 'notifications-ruby-client'
gem 'oauth2'
gem 'paper_trail'
gem 'pg'
gem 'prometheus_exporter'
gem 'puma'
gem 'redis'
gem 'routing-filter'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sidekiq'
gem 'slack-notifier'
gem 'uk_postcode'
gem 'validate_url'

# Swagger API documentation. We need CORS to enable the Swagger UI to make requests
# against the API without an Access-Control-Allow-Origin error.
gem 'rack-cors'
gem 'rswag-api'
gem 'rswag-ui'

# Augments Rails logging to output JSON for Fluentd/Kibana
# on Cloud Platform
gem 'lograge'
gem 'logstash-event'
gem 'logstash-logger'

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
  gem 'rswag-specs'
  gem 'shoulda-matchers'
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
  gem 'rack-test'
  gem 'service_mock'
  gem 'simplecov', require: false
end

group :production do
  # usage docs for application_insights gem at
  # https://github.com/microsoft/ApplicationInsights-Ruby
  # Gem to add insights automatically to a Rack application
  # enhanced to support a RequestTracker with an ignore list
  gem 'appinsights', github: 'ministryofjustice/appinsights'
end
