# frozen_string_literal: true

class NomisClient
  class Alerts
    class << self
      def get(prison_number)
        NomisClient.get("/bookings/offenderNo/#{prison_number}/alerts").parsed.map do |alert|
          attributes_for(alert)
        end
      end

      # rubocop:disable Metrics/MethodLength
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
          rnum: alert['rnum']
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
