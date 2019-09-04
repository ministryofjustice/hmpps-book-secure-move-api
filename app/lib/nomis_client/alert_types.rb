# frozen_string_literal: true

module NomisClient
  class AlertTypes < NomisClient::Base
    class << self
      def get
        fetch_response.parsed.map do |alert_type|
          attributes_for(alert_type)
        end
      end

      def as_hash
        get.map { |alert_type| [alert_type[:code], alert_type] }.to_h.with_indifferent_access
      end

      def fetch_response
        NomisClient::Base.get(
          '/reference-domains/domains/ALERT',
          headers: { 'Page-Limit' => '1000' }
        )
      end

      def attributes_for(alert_type)
        {
          parent_code: alert_type['parentCode'],
          code: alert_type['code'],
          description: alert_type['description'],
          domain: alert_type['domain'],
          parent_domain: alert_type['parentDomain'],
          active_flag: alert_type['activeFlag']
        }
      end
    end
  end
end
