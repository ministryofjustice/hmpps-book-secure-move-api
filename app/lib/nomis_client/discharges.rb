# frozen_string_literal: true

module NomisClient
  class Discharges
    class << self
      def get(agency_id:, date:)
        NomisClient::Base.get("/movements/#{agency_id}/out/#{date.iso8601}?movementType=REL").parsed
      end
    end
  end
end
