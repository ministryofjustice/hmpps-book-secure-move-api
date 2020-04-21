# frozen_string_literal: true

module People
  class RetrieveCourtCases
    def self.call(person, _court_case_filter_params)
      nomis_court_cases_response = NomisClient::CourtCases.get(person.latest_nomis_booking_id)

      JSON.parse(nomis_court_cases_response).map do |court_case|
        CourtCase.new.build_from_nomis(court_case)
      end
    end
  end
end
