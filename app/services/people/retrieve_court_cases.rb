# frozen_string_literal: true

module People
  class RetrieveCourtCases
    class << self
      def call(person, filter_params)
        check_presence_of_latest_nomis_booking_id(person)

        nomis_court_cases_response = NomisClient::CourtCases.get(person.latest_nomis_booking_id, filter_params)

        court_cases = JSON.parse(nomis_court_cases_response).map do |court_case|
          CourtCase.new.build_from_nomis(court_case)
        end

        OpenStruct.new(success?: true, court_cases: court_cases, errors: nil)
      rescue OAuth2::Error => e
        nomis_error = NomisClient::ApiError.new(status: e.response.status, error_body: e.response.body)
        OpenStruct.new(success?: false, court_cases: [], error: nomis_error)
      end

    private

      def check_presence_of_latest_nomis_booking_id(person)
        profile = person.latest_profile

        if profile.latest_nomis_booking_id.nil?
          profile.errors.add(:latest_nomis_booking_id, :blank, message: "can't be blank")

          raise ActiveRecord::RecordInvalid.new(profile)
        end
      end
    end
  end
end
