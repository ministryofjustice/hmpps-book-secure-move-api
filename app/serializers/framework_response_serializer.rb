# frozen_string_literal: true

class FrameworkResponseSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :framework_responses

  belongs_to :assessment, polymorphic: true, &:assessmentable
  belongs_to :question, serializer: FrameworkQuestionSerializer, object_method_name: 'framework_question', id_method_name: 'framework_question_id'
  has_many_if_included :flags, serializer: FrameworkFlagSerializer, &:framework_flags
  has_many_if_included :nomis_mappings, serializer: FrameworkNomisMappingSerializer, &:framework_nomis_mappings

  attributes :value, :responded, :prefilled, :value_type

  SUPPORTED_RELATIONSHIPS = %w[
    assessment
    nomis_mappings
    question.descendants
    flags
  ].freeze
end
