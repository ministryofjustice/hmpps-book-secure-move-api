# frozen_string_literal: true

module NomisClient
  # Sadly can't get VCR to work (yet) so can't auto-test this
  # :nocov:
  class Image < NomisClient::Base
    class << self
      def get(person)
        booking_id = person.latest_profile.latest_nomis_booking_id

        image_route = "/bookings/#{booking_id}/image/data"
        begin
          NomisClient::Base.get(image_route).body
        rescue OAuth2::Error => e
          # We are currently calling Faraday via the OAuth2::Client which
          # results in it wrapping errors inside an OAuth2::Error object
          if e.response.status == 404
            nil
          else
            raise
          end
        end
      end
    end
  end
end
