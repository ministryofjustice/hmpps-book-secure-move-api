# frozen_string_literal: true

class FrameworkQuestionSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :framework_questions

  belongs_to :framework

  attributes :key, :section, :question_type, :options, :response_type

  has_many_if_included :descendants, serializer: FrameworkQuestionSerializer, &:dependents

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    descendants
  ].freeze
end
