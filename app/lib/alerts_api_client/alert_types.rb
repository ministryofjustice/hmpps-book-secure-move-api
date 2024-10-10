# frozen_string_literal: true

module AlertsApiClient
  class AlertTypes < AlertsApiClient::Base
    class << self
      def get
        fetch_response.map { |alert_type|
          alert_type['alertCodes'].map do |alert_code|
            attributes_for(alert_type, alert_code)
          end
        }.flatten
      end

      def fetch_response
        AlertsApiClient::Base.get(
          'alert-types',
          headers: { 'Page-Limit' => '1000' },
        ).parsed
      end

      def attributes_for(alert_type, alert_code)
        {
          code: alert_code['code'],
          type_code: alert_type['code'],
          description: alert_code['description'],
          type_description: alert_type['description'],
          active_flag: alert_type['isActive'],
        }
      end
    end
  end
end
