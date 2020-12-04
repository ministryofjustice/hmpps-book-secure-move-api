# frozen_string_literal: true

class FrameworkResponseSerializer
  include JSONAPI::Serializer

  set_type :framework_responses

  belongs_to :assessment, polymorphic: true, &:assessmentable
  belongs_to :question, serializer: FrameworkQuestionSerializer, &:framework_question
  has_many :flags, serializer: FrameworkFlagSerializer, &:framework_flags
  has_many :nomis_mappings, serializer: FrameworkNomisMappingSerializer, &:framework_nomis_mappings

  attributes :value, :responded, :prefilled

  attribute :value_type do |object|
    object.framework_question.response_type
  end

  SUPPORTED_RELATIONSHIPS = %w[
    assessment
    nomis_mappings
    question.descendants
    flags
  ].freeze
end
