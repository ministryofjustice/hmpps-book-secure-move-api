# frozen_string_literal: true

module NomisClient
  class CourtHearing < NomisClient::Base
    class << self
      def post(booking_id:, court_case_id:, body_params: {})
        court_cases_route = "/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings"

        nomis_response = NomisClient::Base.post(court_cases_route, body: body_params.to_json)

        #TODO: remove this once court to hearing feature is deployed
        Raven.capture_message('CourtHearings:CreateInNomis success!',
                              extra: {
                                  court_cases_route: court_cases_route,
                                  body_params: body_params,
                                  nomis_response: {
                                      status: nomis_response.status,
                                      body: nomis_response.body,
                                  },
                              },
                              level: 'warning')
        nomis_response.body
      rescue OAuth2::Error => e
        Raven.capture_message('CourtHearings:CreateInNomis Error!',
                              extra: {
                                  court_cases_route: court_cases_route,
                                  body_params: body_params,
                                  nomis_response: {
                                      status: e.response.status,
                                      body: e.response.body,
                                  },
                              },
                              level: 'warning')
      end
    end
  end
end
