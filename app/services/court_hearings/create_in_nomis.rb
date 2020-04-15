module CourtHearings
  class CreateInNomis
    def self.call(move, court_hearings)
      booking_id = move.person.latest_nomis_booking_id

      body_locations = {
          "fromPrisonLocation": move.from_location.nomis_agency_id,
          "toCourtLocation": move.to_location.nomis_agency_id,
      }

      court_hearings.each do |hearing|
        NomisClient::CourtHearing.post(booking_id: booking_id,
                                       court_case_id: hearing.nomis_case_id,
                                       body_params: {
                                           'courtHearingDateTime': hearing.start_time.iso8601,
                                           'comments': hearing.comments,
                                       }.merge(body_locations))
      end
    end
  end
end
