# frozen_string_literal: true

module NomisClient
  class Base < HmppsApiClient
    class << self
    protected

      def site_for_api
        ENV['NOMIS_SITE_FOR_API']
      end

      def token_request_path_prefix
        ENV['NOMIS_PRISON_API_PATH_PREFIX']
      end
    end
  end
end
