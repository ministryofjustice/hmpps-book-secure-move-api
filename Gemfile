# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'active_model_serializers', '~> 0.10.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'pg', '~> 1.0.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.2', '>= 5.2.2.1'

group :development, :test do
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
