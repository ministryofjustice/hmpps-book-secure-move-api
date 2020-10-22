# frozen_string_literal: true

module NomisClient
  class PrisonerCategory
    class << self
      def get(nomis_booking_id)
        attributes_for(
          get_response(nomis_booking_id),
        )
      end

      def get_response(nomis_booking_id)
        NomisClient::Base.get("/bookings/#{nomis_booking_id}").parsed
      end

      def attributes_for(details)
        {
          category: details['category'],
          category_code: details['categoryCode'],
        }
      end
    end
  end
end
