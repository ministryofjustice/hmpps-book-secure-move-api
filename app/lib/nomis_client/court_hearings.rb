# frozen_string_literal: true

module NomisClient
  class CourtHearings < NomisClient::Base
    class << self
      def get(booking_id, start_date = Date.today, end_date = Date.today)
        court_hearings_path = "/bookings/#{booking_id}/court-hearings?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}"

        court_hearings = []

        paginate_through(court_hearings_path) do |court_hearings_response|
          hearings_json = court_hearings_response["hearings"]

          hearings_json.each do |hearing_json|
            court_hearings << hearing_json
          end

          hearings_json
        end

        court_hearings
      end

      def post(booking_id:, court_case_id:, body_params: {})
        court_hearings_path = "/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings"

        nomis_response = NomisClient::Base.post(court_hearings_path, body: body_params.to_json)

        # TODO: remove this once court to hearing feature is deployed
        Raven.capture_message('CourtHearings:CreateInNomis success!',
                              extra: {
                                  court_cases_route: court_hearings_path,
                                  body_params: body_params,
                                  nomis_response: {
                                      status: nomis_response.status,
                                      body: nomis_response.body,
                                  },
                              },
                              level: 'warning')

        nomis_response
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
                              level: 'warning')

        e.response
      end
    end
  end
end
