# frozen_string_literal: true

module NomisClient
  class Movements
    class << self
      def get(agency_id:, date:)
        return {} if HmppsApiClient.dps_services_disabled?('Prison API: get movements')

        NomisClient::Base.get("/movements/rollcount/#{agency_id}/movements?movementDate=#{date.iso8601}").parsed
      end
    end
  end
end
