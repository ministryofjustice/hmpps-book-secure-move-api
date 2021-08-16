module CourtHearings
  class CreateInNomis
    def self.call(move, court_hearings)
      booking_id = move.person.latest_nomis_booking_id

      body_locations = {
        fromPrisonLocation: move.from_location.nomis_agency_id,
        toCourtLocation: move.to_location.nomis_agency_id,
      }

      log_attributes = []

      court_hearings.each do |hearing|
        body = {
          booking_id: booking_id,
          court_case_id: hearing.nomis_case_id,
          body_params: {
            courtHearingDateTime: hearing.start_time.to_s(:nomis),
            comments: hearing.comments,
          }.merge(body_locations),
        }
        response = NomisClient::CourtHearings.post(body)

        log_attributes << { response_status: response&.status, response_body: response&.body, request_params: body }

        next unless response&.status == 201

        new_hearing_id = JSON.parse(response.body)['id']

        hearing.update!(nomis_hearing_id: new_hearing_id, saved_to_nomis: true)
      end

      log_attributes
    end
  end
end
