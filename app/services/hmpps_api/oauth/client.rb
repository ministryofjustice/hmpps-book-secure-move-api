# frozen_string_literal: true

module HmppsApi
  module Oauth
    class Client
      include ClientHelper

      def initialize(host)
        @host = host
        @connection = Faraday.new do |faraday|
          faraday.request :retry, max: 3, interval: 0.05,
                                  interval_randomness: 0.5, backoff_factor: 2,
                                  # We appear to get occasional transient 5xx errors, so retry them
                                  retry_statuses: [500, 502],
                                  methods: %i[delete get head options put post]

          faraday.response :raise_error
          faraday.request :authorization, :basic, ENV['NOMIS_CLIENT_ID'], ENV['NOMIS_CLIENT_SECRET']
        end
      end

      def get(route)
        request(:get, route)
      end

      def post(route)
        request(:post, route)
      end

      def request(method, route)
        response = @connection.send(method) do |req|
          url = URI.join(@host, route).to_s
          req.url(url)
        end

        JSON.parse(response.body)
      end
    end
  end
end
