# frozen_string_literal: true

class FrameworksSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :frameworks

  has_many_if_included :questions, serializer: FrameworkQuestionsSerializer, &:framework_questions

  attributes :name, :version

  SUPPORTED_RELATIONSHIPS = %w[
    questions
    questions.descendants.**
    questions.flags
    questions.descendants.flags
  ].freeze
end
