# frozen_string_literal: true

module Alerts
  class Importer
    attr_accessor :profile, :alerts

    def initialize(profile:, alerts:)
      self.profile = profile
      self.alerts = alerts
    end

    def call
      alerts.each do |alert|
        import_alert(alert)
      end
    end

    private

    def import_alert(alert)
      # TODO:
    end
  end
end
