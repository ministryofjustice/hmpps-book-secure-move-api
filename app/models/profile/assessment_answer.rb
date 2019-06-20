# frozen_string_literal: true

class Profile
  class AssessmentAnswer < ActiveModelSerializers::Model
    attributes(
      :title,
      :comments,
      :assessment_question_id,
      :date,
      :expiry_date,
      :category,
      :key
    )

    attr_accessor :title, :comments, :assessment_question_id, :category, :key
    attr_reader :date, :expiry_date

    validates :assessment_question_id, presence: true

    def initialize(attributes = {})
      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)

      self.title = attributes[:title]
      self.comments = attributes[:comments]
      self.date = attributes[:date]
      self.expiry_date = attributes[:expiry_date]
      self.assessment_question_id = attributes[:assessment_question_id]
      self.category = attributes[:category]
      self.key = attributes[:key]
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
  end
end
