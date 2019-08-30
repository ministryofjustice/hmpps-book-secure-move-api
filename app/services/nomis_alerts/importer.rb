# frozen_string_literal: true

require 'csv'

module NomisAlerts
  class Importer
    attr_accessor :alert_types, :alert_codes

    KNOWN_ALERTS = {
      'Self harm' => :self_harm,
      'Must be segregated' => :hold_separately,
      'Violent' => :violent,
      'Escape' => :escape,
      'Not to be released' => :not_for_release,
      'Health and medical' => :health_issue
    }.freeze

    def initialize(alert_types:, alert_codes:)
      self.alert_types = alert_types.map { |alert_type| [alert_type[:code], alert_type] }.to_h
      self.alert_codes = alert_codes
    end

    def call
      alert_codes.each do |alert|
        import_alert(alert)
      end
    end

    private

    def import_alert(alert)
      alert_type = alert_type_for(alert)
      record = NomisAlert.find_or_initialize_by(code: alert[:code], type_code: alert[:parent_code])
      record.update!(
        description: alert[:description],
        type_description: alert_type[:description]
      )
    end

    def alert_type_for(alert)
      alert_types.fetch(alert[:parent_code])
    end
  end
end
