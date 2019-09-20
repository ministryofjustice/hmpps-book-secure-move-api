# frozen_string_literal: true

module PersonalCareNeeds
  class Importer
    attr_accessor :profile, :personal_care_needs

    FALLBACK_QUESTION_KEY = :pregnant

    def initialize(profile:, personal_care_needs:)
      self.profile = profile
      self.personal_care_needs = personal_care_needs
    end

    def call
      profile.merge_assessment_answers!(
        personal_care_needs.map { |personal_care_need| build(personal_care_need) }
      )
      profile.save!
    end

    private

    # rubocop:disable Metrics/MethodLength
    def build(personal_care_need)
      assessment_question = find_assessment_question(personal_care_need)

      Profile::AssessmentAnswer.new(
        title: personal_care_need[:problem_description],
        assessment_question_id: assessment_question&.id,
        created_at: personal_care_need[:start_date],
        expires_at: personal_care_need[:end_date],
        category: assessment_question&.category || :health,
        key: assessment_question&.key || personal_care_need[:problem_code],
        nomis_alert_code: personal_care_need[:problem_code],
        nomis_alert_type: personal_care_need[:problem_type],
        nomis_alert_description: personal_care_need[:problem_description],
        imported_from_nomis: true
      ).tap(&:set_timestamps)
    end
    # rubocop:enable Metrics/MethodLength

    def find_assessment_question(personal_care_need)
      nomis_alert = NomisAlert.includes(:assessment_question).find_by(
        code: personal_care_need[:problem_code],
        type_code: personal_care_need[:problem_type]
      )
      nomis_alert&.assessment_question || fallback_assessment_question
    end

    def fallback_assessment_question
      @fallback_assessment_question ||= AssessmentQuestion.find_by(key: FALLBACK_QUESTION_KEY)
    end
  end
end
