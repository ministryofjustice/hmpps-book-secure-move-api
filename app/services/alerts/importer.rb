# frozen_string_literal: true

module Alerts
  class Importer
    attr_accessor :profile, :alerts

    def initialize(profile:, alerts:)
      self.profile = profile
      self.alerts = alerts
    end

    def call
      profile.merge_assessment_answers!(
        alerts.map { |alert| build_alert(alert) }
      )
      profile.save!
    end

    private

    # alert_id: alert['alertId'],
    # alert_type: alert['alertType'],
    # alert_type_description: alert['alertTypeDescription'],
    # alert_code: alert['alertCode'],
    # alert_code_description: alert['alertCodeDescription'],
    # comment: alert['comment'],
    # created_at: alert['dateCreated'],
    # expires_at: alert['dateExpires'],
    # expired: alert['expired'],
    # active: alert['active'],
    # rnum: alert['rnum']
    def build_alert(alert)
      #TODO: Look up assessment question mapping (NomisAlerts)
      assessment_question = nil

      Profile::AssessmentAnswer.new(
        title: alert[:description],
        comments: alert[:comments],
        assessment_question_id: assessment_question&.id,
        created_at: alert[:created_at],
        expires_at: alert[:expires_at],
        category: assessment_question&.category || :risk,
        key: assessment_question&.key || alert[:alert_code],
        nomis_alert_code: alert[:alert_code],
        nomis_alert_type: alert[:alert_type]
      ).tap(&:set_timestamps)
    end
  end
end
