# frozen_string_literal: true

class FrameworkAssessmentSerializer
  include JSONAPI::Serializer

  belongs_to :framework

  has_many :responses, serializer: FrameworkResponseSerializer do |object|
    object.framework_responses.includes(:framework_flags, :framework_nomis_mappings, framework_question: [:framework, dependents: :dependents])
  end
  has_many :flags, serializer: FrameworkFlagSerializer do |object|
    object.framework_flags.includes(framework_question: :dependents)
  end

  attributes :confirmed_at, :created_at, :nomis_sync_status

  attribute :version do |object|
    object.framework.version
  end

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
