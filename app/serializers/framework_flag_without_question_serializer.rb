# frozen_string_literal: true

class FrameworkFlagWithoutQuestionSerializer
  include JSONAPI::Serializer

  set_type :framework_flags

  attributes :flag_type, :title, :question_value

  SUPPORTED_RELATIONSHIPS = %w[].freeze
end
