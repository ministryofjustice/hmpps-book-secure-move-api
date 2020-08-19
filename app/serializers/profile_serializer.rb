# frozen_string_literal: true

class ProfileSerializer < ActiveModel::Serializer
  attributes(
    :assessment_answers,
  )

  belongs_to :person, serializer: PersonSerializer
  has_many :documents, serializer: DocumentSerializer
  has_one :person_escort_record, serializer: PersonEscortRecordSerializer

  SUPPORTED_RELATIONSHIPS = %w[documents person].freeze
end
