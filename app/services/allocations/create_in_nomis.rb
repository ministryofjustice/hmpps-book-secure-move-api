module Allocations
  class CreateInNomis
    def self.call(move)
      booking_id = move.person&.latest_nomis_booking_id
      return unless booking_id.present? && move.to_location_id? && move.nomis_event_id.nil?

      body = {
        booking_id:,
        body_params: {
          fromPrisonLocation: move.from_location.nomis_agency_id,
          toPrisonLocation: move.to_location.nomis_agency_id,
          escortType: 'PECS',
          scheduledMoveDateTime: move.date.to_fs(:nomis),
        },
      }

      response = NomisClient::Allocations.post(body)

      if response&.status == 201
        new_event_id = JSON.parse(response.body)['id']
        move.update!(nomis_event_id: new_event_id)
      end

      { response_status: response&.status, response_body: response&.body, request_params: body }.tap do |log_attributes|
        Rails.logger.info("Tried to create a prison to prison transfer in nomis #{log_attributes.to_json}")
      end
    end
  end
end
