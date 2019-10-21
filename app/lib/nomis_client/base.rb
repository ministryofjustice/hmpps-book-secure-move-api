# frozen_string_literal: true

module NomisClient
  class Base
    FIXTURE_DIRECTORY = "#{Rails.root}/db/fixtures/nomis"
    NOMIS_TEST_MODE = 'NOMIS_TEST_MODE'

    class << self
      def get(path, params = {})
        request_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        token.get("#{ENV['NOMIS_API_PATH_PREFIX']}#{path}", params)

        total_request_seconds = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - request_start_time)
        Rails.logger.info "NomisClient request completed (#{total_request_seconds}s): #{ENV['NOMIS_API_PATH_PREFIX']}#{path}"
      end

      def test_mode?
        ENV[NOMIS_TEST_MODE] == 'true'
      end

      private

      REFRESH_TOKEN_TIMEFRAME_IN_SECONDS = 5

      def token
        return @token if @token && !token_expired_or_to_expire?

        @token = client.client_credentials.get_token
      end

      def client
        @client ||= OAuth2::Client.new(
          ENV['NOMIS_CLIENT_ID'],
          ENV['NOMIS_CLIENT_SECRET'],
          site: ENV['NOMIS_SITE'],
          auth_scheme: ENV['NOMIS_AUTH_SCHEME'],
          token_url: "#{ENV['NOMIS_AUTH_PATH_PREFIX']}/oauth/token",
          raise_errors: true
        )
      end

      def token_expired_or_to_expire?
        @token.expires? &&
          (@token.expires_at - REFRESH_TOKEN_TIMEFRAME_IN_SECONDS < Time.now.to_i)
      end
    end
  end
end
