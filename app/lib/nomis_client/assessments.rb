# frozen_string_literal: true

module NomisClient
  class Assessments < NomisClient::Base
    class << self
      def get(booking_id:)
        return [] if booking_id.blank?

        get_response(booking_id: booking_id).map { |assessment| attributes_for(assessment) }
      end

      def get_response(booking_id:)
        NomisClient::Base.get("/bookings/#{booking_id}/assessments").parsed
      end

      def attributes_for(assessment)
        assessment.transform_keys { |key| key.underscore.to_sym }
      end
    end
  end
end
