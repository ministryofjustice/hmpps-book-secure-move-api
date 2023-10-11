module Allocations
  class RemoveFromNomis
    def self.call(move)
      booking_id = move.person&.latest_nomis_booking_id
      return unless booking_id.present? && move.nomis_event_id?

      body = {
        booking_id:,
        event_id: move.nomis_event_id,
        body_params: {
          reasonCode: 'ADMI',
        },
      }

      response = NomisClient::Allocations.put(body)

      if response&.status == 200
        move.update!(nomis_event_id: nil)
      end

      { response_status: response&.status, response_body: response&.body, request_params: body }.tap do |log_attributes|
        Rails.logger.info("Tried to remove a prison to prison transfer from nomis #{log_attributes.to_json}")
      end
    end
  end
end
