# frozen_string_literal: true

module NomisClient
  class AlertCodes < NomisClient::Base
    class << self
      def get
        fetch_response.parsed.map do |alert_code|
          attributes_for(alert_code)
        end
      end

      def fetch_response
        NomisClient::Base.get(
          '/reference-domains/domains/ALERT_CODE',
          headers: { 'Page-Limit' => '1000' },
        )
      end

      def attributes_for(alert_code)
        {
          parent_code: alert_code['parentCode'],
          code: alert_code['code'],
          description: alert_code['description'],
          domain: alert_code['domain'],
          parent_domain: alert_code['parentDomain'],
          active_flag: alert_code['activeFlag'],
        }
      end
    end
  end
end
