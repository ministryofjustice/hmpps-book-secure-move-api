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

    # rubocop:disable Metrics/MethodLength
    def build_alert(alert)
      assessment_question = find_assessment_question(alert)

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
    # rubocop:enable Metrics/MethodLength

    def find_assessment_question(alert)
      nomis_alert = NomisAlert.includes(:assessment_question).find_by(
        code: alert[:alert_code],
        type_code: alert[:alert_type]
      )
      nomis_alert&.assessment_question
    end
  end
end
