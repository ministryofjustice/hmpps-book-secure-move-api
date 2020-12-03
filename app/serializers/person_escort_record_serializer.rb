# frozen_string_literal: true

class PersonEscortRecordSerializer < FrameworkAssessmentSerializer
  belongs_to :profile, serializer: V2::ProfileSerializer
  belongs_to :move, serializer: V2::MoveSerializer

  set_type :person_escort_records

  belongs_to :prefill_source, serializer: PersonEscortRecordPrefillSourceSerializer
end
