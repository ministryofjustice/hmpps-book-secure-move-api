# frozen_string_literal: true

class V2::ProfileSerializer < ActiveModel::Serializer
  attributes(
    :assessment_answers,
  )

  belongs_to :person, serializer: V2::PersonSerializer
  has_many :documents, serializer: DocumentSerializer

  SUPPORTED_RELATIONSHIPS = %w[documents person].freeze
end

