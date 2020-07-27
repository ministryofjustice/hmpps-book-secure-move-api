# frozen_string_literal: true

module NomisClient
  class Allocations < NomisClient::Base
    class << self
      def post(booking_id:, body_params: {})
        allocations_path = "/bookings/#{booking_id}/prison-to-prison"

        NomisClient::Base.post(allocations_path, body: body_params.to_json)
      rescue OAuth2::Error => e
        Raven.capture_message(
          'Allocations::CreateInNomis Error!',
          extra: {
            allocations_route: allocations_path,
            body_params: body_params,
            nomis_response: {
              status: e.response.status,
              body: e.response.body,
            },
          },
          level: 'error',
        )

        e.response
      end
    end
  end
end
