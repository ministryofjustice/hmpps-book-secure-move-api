# frozen_string_literal: true

class HmppsApiClient
  HMPPS_TIMEOUT = 10 # in seconds

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

  protected

    def site_for_api
      # expect a value in the subclass
    end

    def token_request_path_prefix
      # expect a value in the subclass
    end

  private

    REFRESH_TOKEN_TIMEFRAME_IN_SECONDS = 5

    def token_request(method, path, params)
      token.send(method, "#{token_request_path_prefix}#{path}", params)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      Rails.logger.warn "HMPPS Connection Error: #{e.message}"
      raise e
    rescue OAuth2::Error => e
      Rails.logger.warn "HMPPS OAuth Client Error: #{e.message}"
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
        site: site_for_api,
        auth_scheme: ENV['NOMIS_AUTH_SCHEME'],
        token_url: "#{ENV['NOMIS_SITE_FOR_AUTH']}/oauth/token",
        raise_errors: true,
        connection_opts: { request: { timeout: HMPPS_TIMEOUT, open_timeout: HMPPS_TIMEOUT } },
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

    def sentry_extra(path, params, exception)
      response = exception.response

      message = begin
        ActiveSupport::JSON.decode(response.body)['developerMessage']
      rescue StandardError
        nil
      end

      {
        route: path,
        body_params: params,
        nomis_response_status: response.status,
        nomis_response_body: response.body,
        nomis_response_message: message,
      }
    end

    def log_exception(description, path, params, exception)
      Sentry.capture_message(
        description,
        extra: sentry_extra(path, params, exception),
        level: 'error',
      )
    end
  end
end
