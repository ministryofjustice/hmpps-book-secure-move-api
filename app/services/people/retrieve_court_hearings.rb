# frozen_string_literal: true

module People
  class RetrieveCourtHearings
    def self.call(person, start_date, end_date)
      court_hearings = NomisClient::CourtHearings.get(person.latest_nomis_booking_id, start_date, end_date)['hearings']

      court_hearings = court_hearings.map do |nomis_court_hearing|
        NomisCourtHearing.new.build_from_nomis(nomis_court_hearing)
      end

      OpenStruct.new(success?: true, content: court_hearings, errors: nil)
    rescue OAuth2::Error => e
      nomis_error = NomisClient::ApiError.new(status: e.response.status, error_body: e.response.body)

      OpenStruct.new(success?: false, content: [], error: nomis_error)
    end
  end
end
