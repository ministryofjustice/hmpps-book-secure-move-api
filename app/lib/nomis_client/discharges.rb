# frozen_string_literal: true

module NomisClient
  class Discharges
    class << self
      def get(agency_id:, date:)
        return [] if HmppsApiClient.dps_services_disabled?('Prison API: get discharges')

        NomisClient::Base.get("/movements/#{agency_id}/out/#{date.iso8601}?movementType=REL").parsed
      end
    end
  end
end
