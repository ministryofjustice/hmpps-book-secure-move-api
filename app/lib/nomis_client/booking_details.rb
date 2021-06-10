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

    private

      def get_response(nomis_booking_id)
        path = "/bookings/#{nomis_booking_id}"
        begin
          NomisClient::Base.get(path).parsed
        rescue OAuth2::Error => e
          log_exception('Get BookingDetails Error', path, {}, e)
          raise e
        end
      end

      def relevant_attributes
        # NB: although other details are available, we just want the prisoner category and csra for now
        %w[category categoryCode csra]
      end

      def attributes_for(details)
        no_details.merge(details.slice(*relevant_attributes).transform_keys { |key| key.underscore.to_sym })
      end

      def no_details
        relevant_attributes.map { |key| [key.underscore.to_sym, nil] }.to_h
      end
    end
  end
end
