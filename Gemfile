# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version')

gem 'rails', '~> 7.1.4'

gem 'activerecord-import'
gem 'auto_strip_attributes'
gem 'aws-sdk-athena'
gem 'aws-sdk-s3'
gem 'bcrypt', require: false
gem 'bootsnap', require: false
gem 'cancancan'
gem 'csv'
gem 'discard'
gem 'doorkeeper', '5.5.4'
gem 'faraday'
gem 'faraday-net_http_persistent'
gem 'faraday-retry'
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
gem 'prometheus-client'
gem 'puma'
gem 'redis'
gem 'routing-filter', github: 'nduitz/routing-filter', ref: '7ada2f1854563852c615eec681c67f80f135ade5'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sidekiq'
gem 'slack-notifier'
gem 'terminal-table'
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
  gem 'bullet'
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
  gem 'spring', '>= 3'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'climate_control'
  gem 'database_cleaner-active_record'
  gem 'rack-test'
  gem 'service_mock'
  gem 'simplecov', require: false
end
