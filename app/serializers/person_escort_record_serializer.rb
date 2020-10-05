# frozen_string_literal: true

class PersonEscortRecordSerializer
  include JSONAPI::Serializer

  set_type :person_escort_records

  belongs_to :profile, serializer: V2::ProfileSerializer
  belongs_to :move, serializer: V2::MoveSerializer
  belongs_to :framework

  has_many :responses, serializer: FrameworkResponseSerializer do |object|
    object.framework_responses.includes(:framework_flags, :framework_nomis_mappings, framework_question: [:framework, dependents: :dependents])
  end
  has_many :flags, serializer: FrameworkFlagSerializer do |object|
    object.framework_flags.includes(framework_question: :dependents)
  end

  attributes :confirmed_at, :created_at

  attribute :version do |object|
    object.framework.version
  end

  attribute :status do |object|
    object.status == 'unstarted' ? 'not_started' : object.status
  end

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
  ].freeze
end
