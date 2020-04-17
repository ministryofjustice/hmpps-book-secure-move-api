# frozen_string_literal: true

module NomisClient
  class CourtCases < NomisClient::Base
    class << self
      ACTIVE_CASES_FILTER = 'activeOnly=true'

      def get(booking_id)
        court_cases_route = "/bookings/#{booking_id}/court-cases?#{ACTIVE_CASES_FILTER}"

        NomisClient::Base.get(court_cases_route).body
      end
    end
  end
end
