# frozen_string_literal: true

module AlertsApiClient
  class Alerts < AlertsApiClient::Base
    class << self
      def get(prison_number)
        JSON.parse(fetch_response(prison_number).body)['content'].map do |alert|
          attributes_for(alert)
        end
      end

      def fetch_response(prison_number)
        AlertsApiClient::Base.get(
          "/prisoners/#{prison_number}/alerts?isActive=true",
        )
      end

      def attributes_for(alert)
        {
          alert_id: alert['alertUuid'],
          alert_type: alert['alertCode']['alertTypeCode'],
          alert_type_description: alert['alertCode']['alertTypeDescription'],
          alert_code: alert['alertCode']['code'],
          alert_code_description: alert['alertCode']['description'],
          comment: (alert['comments'] || []).join('. '),
          created_at: alert['createdAt'],
          expires_at: alert['activeTo'],
          expired: !alert['isActive'],
          active: alert['isActive'],
          prison_number: alert['prisonNumber'],
        }
      end
    end
  end
end
