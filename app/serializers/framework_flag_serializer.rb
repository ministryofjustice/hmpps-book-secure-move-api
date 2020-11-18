# frozen_string_literal: true

class FrameworkFlagSerializer
  include JSONAPI::Serializer

  set_type :framework_flags

  belongs_to :question, serializer: FrameworkQuestionSerializer, &:framework_question

  attributes :flag_type, :title, :question_value

  SUPPORTED_RELATIONSHIPS = %w[
    question
  ].freeze
end
