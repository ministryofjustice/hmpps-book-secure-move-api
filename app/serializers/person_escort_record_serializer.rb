# frozen_string_literal: true

class PersonEscortRecordSerializer < FrameworkAssessmentSerializer
  set_type :person_escort_records

  belongs_to :prefill_source, serializer: PersonEscortRecordPrefillSourceSerializer
end
