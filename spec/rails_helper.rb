# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start :rails do
    add_filter 'app/channels'
    # app doesn't send emails (yet)
    add_filter 'app/mailers/application_mailer.rb'

    # The intention of this value is that it should never go down after a PR
    # It is a (very) naive attempt to prevent untested code entering the codebase
    minimum_coverage 97
    # cope with a small drop from last time due to potential branch differences
    maximum_coverage_drop 0.25
  end
end

ENV['GOVUK_NOTIFY_ENABLED'] = 'true'

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema! unless ENV['SKIP_MAINTAIN_TEST_SCHEMA']
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # Use DB cleaner instead of Rspec's own transactional fixtures
  # (it works better on CircleCI)
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.include RSpec::JsonExpectations::Matchers
  config.include ActiveSupport::Testing::TimeHelpers

  config.before do |example|
    # The PrisonerSearchApiClient makes external HTTP calls to fetch prisoner location data
    # whenever a Move is serialized. This creates test dependencies on external services
    # and slows down the test suite. We stub these calls by default for all specs.
    #
    # If you need to test the actual API client behavior, tag your spec with
    # `with_location_description_api` to bypass this stubbing.
    #
    unless example.metadata[:with_location_description_api]
      location_description_double = class_double(
        PrisonerSearchApiClient::LocationDescription,
        get: '[STUBBED API] Location description from stub',
      )

      response_double = instance_double(
        OAuth2::Response,
        body: { locationDescription: '[STUBBED API] Location from response' }.to_json,
      )

      allow(location_description_double).to receive(:fetch_response).and_return(response_double)

      # Replace the real class with our verified double
      stub_const('PrisonerSearchApiClient::LocationDescription', location_description_double)
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Kaminari.configure do |config|
  config.default_per_page = 5
end

Rails.application.load_tasks
