# frozen_string_literal: true

class FrameworkAssessmentSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  belongs_to :framework

  has_many_if_included :responses, serializer: FrameworkResponseSerializer, &:framework_responses
  has_many_if_included :flags, serializer: FrameworkFlagSerializer, &:framework_flags

  attributes :completed_at, :confirmed_at, :created_at, :nomis_sync_status

  attribute :version do |object|
    object.framework.version
  end

  # "not_started" cannot be used as the name of the enum due to warnings in the model
  # that it starts with a "not_", however we surface this as "not_started" for readability.
  attribute :status do |object|
    object.status == 'unstarted' ? 'not_started' : object.status
  end

  attribute :editable, &:editable?

  meta do |object|
    { section_progress: object.section_progress }
  end

  SUPPORTED_RELATIONSHIPS = %w[
    move
    framework
    profile.person
    responses.question
    responses.nomis_mappings
    responses.question.descendants.**
    flags
    prefill_source
  ].freeze
end
