module FrameworkNomisMappings
  class Alerts
    attr_reader :prison_number, :nomis_sync_status

    def initialize(prison_number:, nomis_sync_status: FrameworkNomisMappings::NomisSyncStatus.new(resource_type: 'alerts'))
      @prison_number = prison_number
      @nomis_sync_status = nomis_sync_status
    end

    def call
      return [] unless prison_number

      build_mappings.compact
    end

  private

    def imported_alerts
      @imported_alerts ||= AlertsApiClient::Alerts.get(prison_number).tap { nomis_sync_status.set_success }
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, OAuth2::Error => e
      Rails.logger.warn "Importing Framework alert mappings Error: #{e.message}"
      nomis_sync_status.set_failure(message: e.message)

      []
    end

    def build_mappings
      imported_alerts.map do |imported_alert|
        next unless imported_alert[:active] == true && imported_alert[:expired] == false

        FrameworkNomisMapping.new(
          raw_nomis_mapping: imported_alert,
          code_type: 'alert',
          code: imported_alert[:alert_code],
          code_description: imported_alert[:alert_code_description],
          comments: imported_alert[:comment],
          creation_date: imported_alert[:created_at],
          expiry_date: imported_alert[:expires_at],
        )
      end
    end
  end
end
