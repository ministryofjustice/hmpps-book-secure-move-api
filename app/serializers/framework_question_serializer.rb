# frozen_string_literal: true

class FrameworkQuestionSerializer
  include JSONAPI::Serializer

  set_type :framework_questions

  belongs_to :framework

  attributes :key, :section, :question_type, :options, :response_type

  has_many :descendants, serializer: FrameworkQuestionSerializer, &:dependents

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    descendants
  ].freeze
end
