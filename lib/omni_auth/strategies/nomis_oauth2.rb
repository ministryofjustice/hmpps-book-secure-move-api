# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class NomisOauth2 < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'nomis_oauth2'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option(
        :client_options,
        site: ENV['FRONT_END_OAUTH_HOST'],
        authorize_url: "#{ENV['FRONT_END_OAUTH_HOST']}/auth/oauth/authorize",
        token_url: "#{ENV['FRONT_END_OAUTH_HOST']}/auth/oauth/token",
        redirect_url: ENV['FRONT_END_OAUTH_REDIRECT_URL'],
        callback: ENV['FRONT_END_OAUTH_CALLBACK_URL']
      )

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['id'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/auth/api/user/me').parsed
      end

      def build_access_token
        options.token_params[:headers] = { 'Authorization' => basic_auth_header }
        super
      end

      def basic_auth_header
        'Basic ' + Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
      end
    end
  end
end
