# frozen_string_literal: true

module NomisClient
  class Image < NomisClient::Base
    class << self
      def get booking_id
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
        # NomisClient::Base.get(image_route).body
      end
    end
  end
end
