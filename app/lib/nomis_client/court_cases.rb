# frozen_string_literal: true

module NomisClient
  class CourtCases < NomisClient::Base
    class << self
      def get(booking_id)
        court_cases_route = "/bookings/#{booking_id}/court-cases"

        begin
          NomisClient::Base.get(court_cases_route).body
        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
