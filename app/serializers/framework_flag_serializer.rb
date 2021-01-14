# frozen_string_literal: true

class FrameworkFlagSerializer
  include JSONAPI::Serializer

  set_type :framework_flags

  belongs_to :question, serializer: FrameworkQuestionSerializer, object_method_name: :framework_question, id_method_name: :framework_question_id

  attributes :flag_type, :title, :question_value

  SUPPORTED_RELATIONSHIPS = %w[
    question
  ].freeze
end
