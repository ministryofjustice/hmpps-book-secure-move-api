# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'active_model_serializers', '~> 0.10.0'
gem 'bcrypt', require: false
gem 'bootsnap', '>= 1.1.0', require: false
gem 'doorkeeper'
gem 'json-schema'
gem 'kaminari'
gem 'oauth2'
gem 'pager_api'
gem 'pg', '~> 1.0.0'
gem 'prometheus_exporter'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.3'
gem 'rswag-api'
gem 'rswag-ui'
gem 'sentry-raven'

group :development, :test do
  gem 'dotenv'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'climate_control'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
