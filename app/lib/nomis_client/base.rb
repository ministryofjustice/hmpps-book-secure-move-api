# frozen_string_literal: true

module NomisClient
  class Base
    NOMIS_TIMEOUT = 10 # in seconds
    FIXTURE_DIRECTORY = Rails.root.join 'db/fixtures/nomis'

    class << self
      def get(path, params = {})
        token_request(:get, path, params)
      end

      def post(path, params = {})
        params = update_json_headers(params)
        token_request(:post, path, params)
      end

      def put(path, params = {})
        params = update_json_headers(params)
        token_request(:put, path, params)
      end

    private

      REFRESH_TOKEN_TIMEFRAME_IN_SECONDS = 5

      def token_request(method, path, params)
        token.send(method, "#{ENV['NOMIS_PRISON_API_PATH_PREFIX']}#{path}", params)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
        Rails.logger.warn "Nomis Connection Error: #{e.message}"
        raise e
      rescue OAuth2::Error => e
        Rails.logger.warn "Nomis OAuth Client Error: #{e.message}"
        raise e
      end

      def token
        return @token if @token && !token_expired_or_to_expire?

        @token = client.client_credentials.get_token
      end

      def client
        @client ||= OAuth2::Client.new(
          ENV['NOMIS_CLIENT_ID'],
          ENV['NOMIS_CLIENT_SECRET'],
          site: ENV['NOMIS_SITE_FOR_API'],
          auth_scheme: ENV['NOMIS_AUTH_SCHEME'],
          token_url: "#{ENV['NOMIS_SITE_FOR_AUTH']}/oauth/token",
          raise_errors: true,
          connection_opts: { request: { timeout: NOMIS_TIMEOUT, open_timeout: NOMIS_TIMEOUT } },
        )
      end

      def token_expired_or_to_expire?
        # rubocop:disable Rails/TimeZone
        @token.expires? &&
          (@token.expires_at - REFRESH_TOKEN_TIMEFRAME_IN_SECONDS < Time.now.to_i)
        # rubocop:enable Rails/TimeZone
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

      def log_exception(description, path, params, exception)
        Sentry.capture_message(description,
                               extra: {
                                 route: path,
                                 body_params: params,
                                 nomis_response: {
                                   status: exception.response.status,
                                   body: exception.response.body,
                                 },
                               },
                               level: 'error')
      end
    end
  end
end
