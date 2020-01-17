# frozen_string_literal: true

module NomisClient
  class Alerts < NomisClient::Base
    class << self
      def get(prison_numbers)
        get_response(nomis_offender_numbers: prison_numbers).map do |alert|
          attributes_for(alert)
        end
      end

      def get_response(nomis_offender_numbers:)
        NomisClient::Base.post(
          '/bookings/offenderNo/alerts',
          body: nomis_offender_numbers.to_json,
        ).parsed
      end

      def attributes_for(alert)
        {
          alert_id: alert['alertId'],
          alert_type: alert['alertType'],
          alert_type_description: alert['alertTypeDescription'],
          alert_code: alert['alertCode'],
          alert_code_description: alert['alertCodeDescription'],
          comment: alert['comment'],
          created_at: alert['dateCreated'],
          expires_at: alert['dateExpires'],
          expired: alert['expired'],
          active: alert['active'],
          offender_no: alert['offenderNo'],
        }
      end
    end
  end
end
