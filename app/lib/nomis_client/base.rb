# frozen_string_literal: true

module NomisClient
  class Base
    FIXTURE_DIRECTORY = Rails.root.join 'db/fixtures/nomis'
    MAX_RETRIES = 2

    PAGE_OFFSET = '0'
    PAGE_LIMIT = '20'

    DEFAULT_PAGINATE_PARAMS = {
      headers: {
        'Page-Offset' => PAGE_OFFSET,
        'Page-Limit' => PAGE_LIMIT,
      },
    }.freeze

    class << self
      def get(path, params = {})
        benchmark_request(path) { token.get("#{ENV['NOMIS_API_PATH_PREFIX']}#{path}", params) }
      end

      def post(path, params = {})
        params = update_json_headers(params)
        benchmark_request(path) { token.post("#{ENV['NOMIS_API_PATH_PREFIX']}#{path}", params) }
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
        )
      end

      def token_expired_or_to_expire?
        @token.expires? &&
          (@token.expires_at - REFRESH_TOKEN_TIMEFRAME_IN_SECONDS < Time.now.to_i)
      end

      def benchmark_request(path)
        retries ||= 0
        request_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        response = yield

        total_request_seconds = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - request_start_time)
        Rails.logger.info "NomisClient request took (#{total_request_seconds}s): #{ENV['NOMIS_API_PATH_PREFIX']}#{path}"

        response
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError
        retries += 1
        retry if retries <= MAX_RETRIES
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

      def paginate_through(path, params = {}, verb = :get)
        responses = []

        params = DEFAULT_PAGINATE_PARAMS.dup.deep_merge(params)
        response = NomisClient::Base.send(verb, path, params)
        responses << response
        total_records = response.headers['total-records'].to_i
        found_records = 0

        return [] if total_records < 1

        if response.status == 200
          collection_items = yield response.parsed

          found_records += collection_items.count
        end

        while found_records < total_records
          offset = params[:headers]['page-offset'].to_i
          params[:headers]['page-offset'] = (offset + 1).to_s

          response = NomisClient::Base.send(verb, path, params)
          responses << response
          total_records = response.headers['total-records'].to_i

          if response.status == 200
            collection_items = yield response.parsed

            found_records += collection_items.count
          end
        end

        responses
      end
    end
  end
end
