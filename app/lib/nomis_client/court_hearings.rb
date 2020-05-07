# frozen_string_literal: true

module NomisClient
  class CourtHearings < NomisClient::Base
    class << self
      def get(booking_id, start_date, end_date)
        court_hearings_path = "/bookings/#{booking_id}/court-hearings?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}"

        response = NomisClient::Base.get(
          court_hearings_path,
          headers: { 'Page-Limit' => '1000' },
        )

        response.parsed
      end

      def post(booking_id:, court_case_id:, body_params: {})
        court_hearings_path = "/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings"

        NomisClient::Base.post(court_hearings_path, body: body_params.to_json)
      rescue OAuth2::Error => e
        Raven.capture_message('CourtHearings:CreateInNomis Error!',
                              extra: {
                                  court_cases_route: court_hearings_path,
                                  body_params: body_params,
                                  nomis_response: {
                                      status: e.response.status,
                                      body: e.response.body,
                                  },
                              },
                              level: 'error')

        e.response
      end
    end
  end
end
