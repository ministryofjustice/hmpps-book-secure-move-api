# frozen_string_literal: true

class V2::ProfileSerializer
  include JSONAPI::Serializer

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person, serializer: ::V2::PersonSerializer
  has_many :documents, serializer: DocumentSerializer

  # TODO: DELETE THIS REFERENCE
  has_one :person_escort_record, serializer: PersonEscortRecordSerializer # NB causes N+1 lookup of person_escort_record

  has_many :person_escort_record_flags, serializer: FrameworkFlagWithoutQuestionSerializer # NB cannot lazy-load, otherwise the profile wont reference PER flags

  INCLUDED_FIELDS = { person_escort_record_flags: ::FrameworkFlagWithoutQuestionSerializer.attributes_to_serialize.keys }.freeze

  SUPPORTED_RELATIONSHIPS = %w[
    documents
    person
    person_escort_record
    person_escort_record_flags
  ].freeze
end
