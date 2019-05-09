# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'active_model_serializers', '~> 0.10.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'json-schema'
gem 'kaminari'
gem 'oauth2'
gem 'pager_api'
gem 'pg', '~> 1.0.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.3'
gem 'rswag'

group :development, :test do
  gem 'factory_bot'
  gem 'faker'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :development do
  gem 'climate_control'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
