# frozen_string_literal: true

class PersonEscortRecordsSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :person_escort_records

  has_many_if_included :flags, serializer: FrameworkFlagsSerializer, &:framework_flags

  attributes :confirmed_at, :created_at, :nomis_sync_status

  attribute :status do |object|
    object.status == 'unstarted' ? 'not_started' : object.status
  end

  meta do |object|
    { section_progress: object.section_progress }
  end
end
