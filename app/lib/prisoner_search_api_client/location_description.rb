# frozen_string_literal: true

module PrisonerSearchApiClient
  class LocationDescription < PrisonerSearchApiClient::Base
    class << self
      def get(prison_number)
        return nil unless prison_number

        JSON.parse(fetch_response(prison_number).body)['locationDescription']
      rescue OAuth2::Error
        nil
      end

      def fetch_response(prison_number)
        PrisonerSearchApiClient::Base.get("/prisoner/#{prison_number}")
      end
    end
  end
end
