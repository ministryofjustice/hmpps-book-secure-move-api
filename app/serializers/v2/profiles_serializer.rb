# frozen_string_literal: true

class V2::ProfilesSerializer
  include JSONAPI::Serializer

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person, serializer: ::V2::PersonSerializer
  has_one :person_escort_record, serializer: PersonEscortRecordsSerializer
end
