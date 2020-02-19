# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'active_model_serializers', '~> 0.10.0'
gem 'aws-sdk-s3', require: false
gem 'bcrypt', require: false
gem 'bootsnap', '>= 1.1.0', require: false
gem 'cancancan'
# explicit soft-deletes
gem 'discard'
gem 'doorkeeper'
gem 'faraday'
# static page serving for extra API documentation
gem 'high_voltage'
gem 'json-schema'
gem 'kaminari'
gem 'markdown-rails'
gem 'net-http-persistent'
gem 'nokogiri', '>= 1.10.4'
gem 'oauth2'
gem 'pager_api'
gem 'paper_trail'
gem 'pg', '~> 1.0.0'
gem 'prometheus_exporter'
gem 'puma', '~> 3.12.2'
gem 'rails', '~> 5.2.3'
gem 'sassc-rails'
gem 'sentry-raven'
gem 'sidekiq'
gem 'tty-prompt'
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
  gem 'dotenv', '~> 2.7'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails'
  gem 'faker'
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
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop-govuk'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'climate_control'
  gem 'simplecov', require: false
end
