# frozen_string_literal: true

class V2::ProfileSerializer
  include JSONAPI::Serializer

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person, serializer: ::V2::PersonSerializer
  has_many :documents, serializer: DocumentSerializer
  has_one :person_escort_record, serializer: PersonEscortRecordSerializer, lazy_load_data: true
  has_many :person_escort_record_flags, serializer: FrameworkFlagSerializer, lazy_load_data: true

  SUPPORTED_RELATIONSHIPS = %w[documents person person_escort_record person_escort_record_flags].freeze
end
