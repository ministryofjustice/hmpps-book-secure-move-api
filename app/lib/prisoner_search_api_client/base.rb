# frozen_string_literal: true

module PrisonerSearchApiClient
  class Base < HmppsApiClient
    class << self
    protected

      def site_for_api
        ENV['PRISONER_SEARCH_API_BASE_URL']
      end

      def token_request_path_prefix
        ''
      end
    end
  end
end
