module CourtHearings
  class CreateInNomis
    def self.call(move, court_hearings)
      booking_id = move.person.latest_nomis_booking_id

      body_locations = {
          "fromPrisonLocation": move.from_location.nomis_agency_id,
          "toCourtLocation": move.to_location.nomis_agency_id,
      }

      court_hearings.each do |hearing|
        response = NomisClient::CourtHearings.post(booking_id: booking_id,
                                       court_case_id: hearing.nomis_case_id,
                                       body_params: {
                                           'courtHearingDateTime': hearing.start_time.utc.iso8601,
                                           'comments': hearing.comments,
                                       }.merge(body_locations))
        if response&.status == 201
          new_hearing_id = JSON.parse(response.body)['id']

          hearing.update(nomis_hearing_id: new_hearing_id, saved_to_nomis: true)
        end
      end
    end
  end
end
