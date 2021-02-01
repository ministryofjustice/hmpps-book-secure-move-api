# frozen_string_literal: true

class PersonEscortRecordSerializer < FrameworkAssessmentSerializer
  # Due to autoloading issues, have mirrored relationships in children classes
  # TODO: when moving off versions, move this back into framework assessment serializer
  belongs_to :profile, serializer: V2::ProfileSerializer
  belongs_to :move, serializer: V2::MoveSerializer

  set_type :person_escort_records

  belongs_to :prefill_source, serializer: PersonEscortRecordPrefillSourceSerializer

  attributes :amended_at, :handover_details, :handover_occurred_at
end
