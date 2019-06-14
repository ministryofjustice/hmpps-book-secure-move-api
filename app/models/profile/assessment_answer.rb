# frozen_string_literal: true

class Profile
  class AssessmentAnswer < ActiveModelSerializers::Model
    attributes(
      :title,
      :comments,
      :assessment_answer_type_id,
      :date,
      :expiry_date,
      :category
    )

    attr_accessor :title, :comments, :assessment_answer_type_id, :category
    attr_reader :date, :expiry_date

    def initialize(attributes = {})
      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)

      self.title = attributes[:title]
      self.comments = attributes[:comments]
      self.date = attributes[:date]
      self.expiry_date = attributes[:expiry_date]
      self.assessment_answer_type_id = attributes[:assessment_answer_type_id]
      self.category = attributes[:category]
      super
    end

    def date=(value)
      @date = value.is_a?(String) ? Date.parse(value) : value
    end

    def expiry_date=(value)
      @expiry_date = value.is_a?(String) ? Date.parse(value) : value
    end

    def empty?
      title.blank?
    end

    def as_json
      {
        title: title,
        comments: comments,
        date: date,
        expiry_date: expiry_date,
        assessment_answer_type_id: assessment_answer_type_id,
        category: category
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

    def set_category
      return unless assessment_answer_type_id.present? && category.blank?

      assessment_answer_type = AssessmentAnswerType.find(assessment_answer_type_id)
      self.category = assessment_answer_type.category
    end
  end
end
