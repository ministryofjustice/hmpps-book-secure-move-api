# frozen_string_literal: true

module AlertsApiClient
  class Base < NomisClient::Base
    class << self
    protected

      def site_for_api
        ENV['ALERTS_API_BASE_URL']
      end

      def token_request_path_prefix
        ''
      end
    end
  end
end
