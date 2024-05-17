# frozen_string_literal: true

class Profile
  class AssessmentAnswer
    include ActiveModel::Model

    attr_accessor(
      :title,
      :comments,
      :assessment_question_id,
      :category,
      :key,
      :nomis_alert_code,
      :nomis_alert_type,
      :nomis_alert_description,
      :nomis_alert_type_description,
      :imported_from_nomis,
    )
    attr_reader(
      :created_at,
      :expires_at,
    )

    validates :assessment_question_id, presence: true
    validates :nomis_alert_type, presence: true, if: ->(assessment_answer) { assessment_answer.imported_from_nomis }
    validates :nomis_alert_code, presence: true, if: ->(assessment_answer) { assessment_answer.imported_from_nomis }

    def initialize(attributes = {})
      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)
      assign_attributes(attributes)
      super
    end

    def created_at=(value)
      @created_at = value.is_a?(String) ? Date.parse(value) : value
    end

    def expires_at=(value)
      @expires_at = value.is_a?(String) ? Date.parse(value) : value
    end

    def empty?
      assessment_question_id.blank?
    end

    def copy_question_attributes
      return if assessment_question_id.blank?

      assessment_question = AssessmentQuestion.find(assessment_question_id)
      self.category = assessment_question.category
      self.key = assessment_question.key
      self.title = assessment_question.title
    end

    def set_timestamps
      self.created_at ||= Time.zone.now
    end

    def self.from_nomis_personal_care_need(personal_care_need, assessment_question, alert_type_description)
      new(
        title: personal_care_need[:problem_description],
        created_at: personal_care_need[:start_date],
        expires_at: personal_care_need[:end_date],
        nomis_alert_code: personal_care_need.fetch(:problem_code),
        nomis_alert_type: personal_care_need.fetch(:problem_type),
        nomis_alert_description: personal_care_need[:problem_description],
        assessment_question_id: assessment_question.id,
        category: assessment_question.category,
        key: assessment_question.key,
        comments: personal_care_need[:commentText],
        nomis_alert_type_description: alert_type_description, # Needs to be oneOf Medical, Maternity status, Disability
        imported_from_nomis: true,
      ).tap(&:set_timestamps)
    end

  private

    def assign_attributes(attributes)
      self.title = attributes[:title]
      self.comments = attributes[:comments]
      self.created_at = attributes[:created_at]
      self.expires_at = attributes[:expires_at]
      self.assessment_question_id = attributes[:assessment_question_id]
      self.category = attributes[:category]
      self.key = attributes[:key]
      self.nomis_alert_code = attributes[:nomis_alert_code]
      self.nomis_alert_type = attributes[:nomis_alert_type]
      self.nomis_alert_description = attributes[:nomis_alert_description]
      self.nomis_alert_type_description = attributes[:nomis_alert_type_description]
      self.imported_from_nomis = attributes[:imported_from_nomis]
    end
  end
end
