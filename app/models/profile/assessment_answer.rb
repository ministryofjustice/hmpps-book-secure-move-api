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
      :nomis_alert_type
    )

    attr_accessor :title, :comments, :assessment_question_id, :category, :key
    attr_reader :created_at, :expires_at

    validate :assessment_question_or_nomis_code_present

    def initialize(attributes = {})
      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)

      self.title = attributes[:title]
      self.comments = attributes[:comments]
      self.created_at = attributes[:created_at]
      self.expires_at = attributes[:expires_at]
      self.assessment_question_id = attributes[:assessment_question_id]
      self.category = attributes[:category]
      self.key = attributes[:key]
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
        key: key
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
      return unless assessment_question_id.present?

      assessment_question = AssessmentQuestion.find(assessment_question_id)
      self.category = assessment_question.category
      self.key = assessment_question.key
      self.title = assessment_question.title
    end

    def set_timestamps
      self.created_at ||= Time.zone.now
    end

    def assessment_question_or_nomis_code_present
      return if assessment_question_id.present? || (nomis_alert_type.present? && nomis_alert_code.present?)

      errors.add(:assessment_question_id, "can't be blank unless nomis_alert_type and nomis_alert_code are present")
    end
  end
end
