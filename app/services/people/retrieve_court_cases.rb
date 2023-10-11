# frozen_string_literal: true

module People
  class RetrieveCourtCases
    def self.call(person, filter_params)
      nomis_court_cases_response = NomisClient::CourtCases.get(person.latest_nomis_booking_id, filter_params)

      court_cases = JSON.parse(nomis_court_cases_response).map do |court_case|
        CourtCase.new.build_from_nomis(court_case)
      end

      OpenStruct.new(success?: true, court_cases:, errors: nil)
    rescue OAuth2::Error => e
      nomis_error = NomisClient::ApiError.new(status: e.response.status, error_body: e.response.body)
      OpenStruct.new(success?: false, court_cases: [], error: nomis_error)
    end
  end
end
