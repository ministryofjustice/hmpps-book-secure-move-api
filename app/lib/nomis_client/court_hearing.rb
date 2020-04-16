# frozen_string_literal: true

module NomisClient
  class CourtHearing < NomisClient::Base
    class << self
      def post(booking_id:, court_case_id:, body_params: {})
        court_cases_route = "/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings"

        NomisClient::Base.post(court_cases_route, body: body_params.to_json).body
      end
    end
  end
end
