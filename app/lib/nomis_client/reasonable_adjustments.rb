# frozen_string_literal: true

module NomisClient
  class ReasonableAdjustments < NomisClient::Base
    class << self
      def get(booking_id:, reasonable_adjustment_types:)
        return [] unless booking_id.present? && reasonable_adjustment_types.present?

        reasonable_adjustments_response = get_response(booking_id:, reasonable_adjustment_types:)

        reasonable_adjustments_response['reasonableAdjustments'].map do |reasonable_adjustment_attributes|
          attributes_for(reasonable_adjustment_attributes)
        end
      end

      def get_response(booking_id:, reasonable_adjustment_types:)
        NomisClient::Base.get(
          "/bookings/#{booking_id}/reasonable-adjustments?type=#{reasonable_adjustment_types}",
        ).parsed
      end

      def attributes_for(reasonable_adjustment)
        {
          treatment_code: reasonable_adjustment['treatmentCode'],
          comment_text: reasonable_adjustment['commentText'],
          start_date: reasonable_adjustment['startDate'],
          end_date: reasonable_adjustment['endDate'],
          agency_id: reasonable_adjustment['agencyId'],
          treatment_description: reasonable_adjustment['treatmentDescription'],
        }
      end
    end
  end
end
