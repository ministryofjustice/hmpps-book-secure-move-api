# frozen_string_literal: true

module People
  class RetrieveCourtHearings
    def self.call(person)
      court_hearings = NomisClient::CourtHearings.get(person.latest_nomis_booking_id)['hearings']

      court_hearings.map do |nomis_court_hearing|
        NomisCourtHearing.new.build_from_nomis(nomis_court_hearing)
      end
    end
  end
end
