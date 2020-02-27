# frozen_string_literal: true

module NomisClient
  class Image < NomisClient::Base
    class << self
      def get booking_id
        detail_result = NomisClient::Base.post(
          '/offender-sentences/bookings',
          body: [booking_id].to_json,
          ).parsed.first

        if detail_result
          image_id = detail_result['facialImageId']

          image_route = "/images/#{image_id}/data"
          NomisClient::Base.get(image_route).body
        end
      end
    end
  end
end
