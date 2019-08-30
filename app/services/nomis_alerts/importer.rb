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
      self.alert_types = alert_types
      self.alert_codes = alert_codes
    end

    def call
      alert_codes.each do |alert|
        record = NomisAlert.find_or_initialize_by(nomis_code: alert[:code])
        puts record.id
      end
    end

    private
  end
end
