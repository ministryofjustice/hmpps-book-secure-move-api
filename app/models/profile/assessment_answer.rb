# frozen_string_literal: true

class Profile
  class AssessmentAnswer < ActiveModelSerializers::Model
    attributes(
      :title,
      :comments,
      :assessment_question_id,
      :created_at,
      :expires_at,
      :category,
      :key,
      :nomis_alert_code,
      :nomis_alert_type,
      :nomis_alert_description,
      :nomis_alert_type_description,
      :imported_from_nomis,
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

    def as_json
      {
        title: title,
        comments: comments,
        created_at: created_at,
        expires_at: expires_at,
        assessment_question_id: assessment_question_id,
        category: category,
        key: key,
        nomis_alert_type: nomis_alert_type,
        nomis_alert_code: nomis_alert_code,
        nomis_alert_type_description: nomis_alert_type_description,
        nomis_alert_description: nomis_alert_description,
        imported_from_nomis: imported_from_nomis,
      }
    end

    def risk?
      category == 'risk'
    end

    def health?
      category == 'health'
    end

    def court?
      category == 'court'
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
