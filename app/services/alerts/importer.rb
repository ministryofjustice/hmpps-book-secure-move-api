# frozen_string_literal: true

module Alerts
  class Importer
    FALLBACK_QUESTION_KEY = :other_risks
    ASSESSMENT_ANSWER_CATEGORY = 'risk'

    def initialize(profile:, alerts:)
      @profile = profile
      @alerts = alerts
    end

    def call
      @profile.merge_assessment_answers!(
        @alerts.map { |alert| build_alert(alert) },
        ASSESSMENT_ANSWER_CATEGORY,
      )
    end

  private

    def build_alert(alert)
      assessment_question = find_assessment_question(alert)
      puts 'ID:'
      puts assessment_question.id

      Profile::AssessmentAnswer.new(
        #  the mapping of these 3 fields is irrelevant because profile.save
        # calls AssessmentAnswer#copy_question_attributes which overwrites these fields
        title: assessment_question.title,
        category: assessment_question.category,
        key: assessment_question.key,

        comments: alert[:comment],
        assessment_question_id: assessment_question.id,
        created_at: alert[:created_at],
        expires_at: alert[:expires_at],
        nomis_alert_code: alert.fetch(:alert_code),
        nomis_alert_type: alert.fetch(:alert_type),
        nomis_alert_description: alert[:alert_code_description],
        nomis_alert_type_description: alert[:alert_type_description],
        imported_from_nomis: true,
      ).tap(&:set_timestamps)
    end

    def find_assessment_question(alert)
      nomis_alert = NomisAlert.includes(:assessment_question).find_by(
        code: alert[:alert_code],
        type_code: alert[:alert_type],
      )
      nomis_alert&.assessment_question || fallback_assessment_question
    end

    def fallback_assessment_question
      @fallback_assessment_question ||= AssessmentQuestion.find_by!(key: FALLBACK_QUESTION_KEY)
    end
  end
end
