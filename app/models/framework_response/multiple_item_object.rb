# frozen_string_literal: true

class FrameworkResponse
  class MultipleItemObject
    include ActiveModel::Validations

    attr_accessor :questions, :item, :responses, :assessmentable

    validates :item, presence: true, numericality: { only_integer: true }
    validates :responses, presence: true
    validate :multiple_response_objects
    validate :required_questions

    def initialize(assessmentable:, attributes: {}, questions: [])
      attributes = attributes.presence || {}
      @questions = questions
      @assessmentable = assessmentable

      attributes.deep_symbolize_keys! if attributes.respond_to?(:deep_symbolize_keys!)
      @item = attributes[:item]
      @responses = attributes[:responses] || []

      validate_responses_type
    end

    def as_json(_options = {})
      return {} unless item.present? && responses.any?

      {
        item: item,
        responses: response_objects.map { |response| response_as_json(response) },
      }
    end

  private

    def multiple_response_objects
      return unless response_objects.any? { |object| object.invalid?(:update) }

      response_objects.each_with_index do |object, index|
        object.errors.each do |error|
          attribute = error.attribute
          message = error.message
          errors.add("responses[#{index}].#{attribute}", message)
        end
      end
    end

    def response_objects
      @response_objects ||= responses.map { |response|
        framework_question = questions.find { |question| question.id == response[:framework_question_id] }
        next unless framework_question

        framework_response = framework_question.build_response(framework_question, assessmentable)

        framework_response.value = response[:value]
        framework_response
      }.compact
    end

    def validate_responses_type
      unless responses.blank? || responses_type_valid?
        raise FrameworkResponse::ValueTypeError, responses
      end
    end

    def responses_type_valid?
      responses.is_a?(::Array) && responses.all?(::Hash)
    end

    def required_questions
      question_ids = responses.map { |response| response[:framework_question_id] }
      questions.each do |question|
        next unless question.required

        errors.add(:responses, 'provide a value for all required questions') unless question_ids.include?(question.id)
      end
    end

    def response_as_json(response)
      {
        value: response.value,
        framework_question_id: response.framework_question_id,
      }
    end
  end
end
