# frozen_string_literal: true

class V2::ProfilesSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person, serializer: ::V2::PersonSerializer

  has_one_if_included :person_escort_record, serializer: PersonEscortRecordsSerializer
end
