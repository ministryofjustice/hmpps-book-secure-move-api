# frozen_string_literal: true

class V2::ProfileSerializer
  include JSONAPI::Serializer

  INCLUDED_ATTRIBUTES = [:assessment_answers]

  set_type :profiles

  attributes(*INCLUDED_ATTRIBUTES)

  belongs_to :person, serializer: ::V2::PersonSerializer

  has_many :documents, serializer: DocumentSerializer

  has_one :person_escort_record, serializer: PersonEscortRecordSerializer

  SUPPORTED_RELATIONSHIPS = %w[documents person person_escort_record].freeze
end
