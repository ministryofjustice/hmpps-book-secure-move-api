# frozen_string_literal: true

module People
  class RetrieveCourtHearings
    def self.call(person)
      court_hearings = NomisClient::CourtHearings.get(person.latest_nomis_booking_id)

      court_hearings.map do |court_hearing_json|
        NomisCourtHearing.new.build_from_nomis(court_hearing_json)
      end
    end
  end
end
