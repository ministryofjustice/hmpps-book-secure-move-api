# frozen_string_literal: true

require 'omni_auth/strategies/nomis_oauth2'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :nomis_oauth2,
    ENV['FRONT_END_OAUTH_CLIENT_ID'],
    ENV['FRONT_END_OAUTH_SECRET']
  )
end
