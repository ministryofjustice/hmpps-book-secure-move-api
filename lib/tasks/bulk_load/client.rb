module Tasks
  module BulkLoad
    class Client

      def initialize(client_id, client_secret, base_url)
        @client_id = client_id
        @client_secret = client_secret
        @base_url = base_url
      end

      def get(path, params = {})
        params = update_json_headers(params)
        response = token_request(:get, path, params)
        parse_response(response, path)
      end

      def post(path, params = {})
        params = update_json_headers(params)
        response = token_request(:post, path, params)
        parse_response(response, path)
      end

      def patch(path, params = {})
        params = update_json_headers(params)
        response = token_request(:patch, path, params)
        parse_response(response, path)
      end

    private

      def client
        @client ||= OAuth2::Client.new(
            @client_id,
            @client_secret,
            site: @base_url,
            auth_scheme: 'basic_auth',
            token_url: "/oauth/token",
            raise_errors: true,
            connection_opts: { request: { timeout: 10, open_timeout: 10 } },
            )
      end

      def token
        return @token if @token && @token.expires? && (@token.expires_at - 5 < Time.now.to_i)
        @token = client.client_credentials.get_token
      end

      def token_request(method, path, params)
        token.send(method, path, params)
      end

      def update_json_headers(params)
        return unless params
        {
          headers:
            {
              'Accept': 'application/vnd.api+json; version=2',
              'Content-Type': 'application/json',
              'Idempotency-Key': SecureRandom.uuid
            },
        }.deep_merge(params)
      end

      def parse_response(response, path)
        if response.status >= 200 && response.status <= 299
          JSON.parse(response.body)['data']
        else
          raise "Non success (#{response.status}) returned for #{path}"
        end
      end
    end
  end
end
