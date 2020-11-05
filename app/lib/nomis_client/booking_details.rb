# frozen_string_literal: true

module NomisClient
  class BookingDetails
    class << self
      def get(nomis_booking_id)
        if nomis_booking_id
          attributes_for(get_response(nomis_booking_id))
        else
          no_details
        end
      end

      def get_response(nomis_booking_id)
        path = "/bookings/#{nomis_booking_id}"
        begin
          NomisClient::Base.get(path).parsed
        rescue OAuth2::Error => e
          log_exception('Get BookingDetails Error', path, {}, e)
          raise e
        end
      end

      def attributes_for(details)
        # NB: although other details are available, we just want the prisoner category for now
        {
          category: details['category'],
          category_code: details['categoryCode'],
        }
      end

      def no_details
        {
          category: nil,
          category_code: nil,
        }
      end
    end
  end
end
