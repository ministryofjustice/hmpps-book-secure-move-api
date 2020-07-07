# frozen_string_literal: true

module NomisClient
  class Base
    NOMIS_TIMEOUT = 10 # in seconds
    FIXTURE_DIRECTORY = Rails.root.join 'db/fixtures/nomis'

    class << self
      def get(path, params = {})
        token.get("#{ENV['NOMIS_API_PATH_PREFIX']}#{path}", params)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
        Rails.logger.warn "Nomis Connection Error: #{e.message}"
        raise e
      end

      def post(path, params = {})
        params = update_json_headers(params)
        token.post("#{ENV['NOMIS_API_PATH_PREFIX']}#{path}", params)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
        Rails.logger.warn "Nomis Connection Error: #{e.message}"
        raise e
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
          raise_errors: true,
          connection_opts: { request: { timeout: NOMIS_TIMEOUT, open_timeout: NOMIS_TIMEOUT } },
        )
      end

      def token_expired_or_to_expire?
        @token.expires? &&
          (@token.expires_at - REFRESH_TOKEN_TIMEFRAME_IN_SECONDS < Time.now.to_i)
      end

      def update_json_headers(params)
        return unless params

        {
          headers:
          {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        }.deep_merge(params)
      end
    end
  end
end
