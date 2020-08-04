# frozen_string_literal: true

module NomisClient
  class Allocations < NomisClient::Base
    class << self
      def post(booking_id:, body_params: {})
        allocations_path = "/bookings/#{booking_id}/prison-to-prison"

        NomisClient::Base.post(allocations_path, body: body_params.to_json)
      rescue OAuth2::Error => e
        log_exception('Allocations::CreateInNomis Error!', allocations_path, body_params, e)

        e.response
      end

      def put(booking_id:, event_id:, body_params: {})
        allocations_path = "/bookings/#{booking_id}/prison-to-prison/#{event_id}/cancel"

        NomisClient::Base.put(allocations_path, body: body_params.to_json)
      rescue OAuth2::Error => e
        log_exception('Allocations::RemoveFromNomis Error!', allocations_path, body_params, e)

        e.response
      end
    end
  end
end
