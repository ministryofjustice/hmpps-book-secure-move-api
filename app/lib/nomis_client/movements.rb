# frozen_string_literal: true

module NomisClient
  class Movements
    class << self
      def get(agency_id:, date:)
        NomisClient::Base.get("/movements/rollcount/#{agency_id}/movements?movementDate=#{date.iso8601}").parsed
      end
    end
  end
end
