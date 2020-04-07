# frozen_string_literal: true

module NomisClient
  class CourtHearing < NomisClient::Base
    class << self
      def post(booking_id, court_case_id)
        court_cases_route = POST "/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings"

        NomisClient::Base.get(court_cases_route).body
      end
    end
  end
end
