# frozen_string_literal: true

class PersonEscortRecordsSerializer
  include JSONAPI::Serializer

  set_type :person_escort_records

  # TODO: confirm whether this includes is really necessary - it seems to cause N+1 issues
  # has_many :flags, serializer: FrameworkFlagSerializer do |object|
  #   object.framework_flags.includes(framework_question: :dependents)
  # end

  has_many :flags, serializer: FrameworkFlagsSerializer, &:framework_flags

  attributes :confirmed_at, :created_at, :nomis_sync_status
end
