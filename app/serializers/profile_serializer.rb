# frozen_string_literal: true

class ProfileSerializer < ActiveModel::Serializer
  attributes(
    :assessment_answers,
  )

  belongs_to :person, serializer: PersonSerializer
  has_many :documents, serializer: DocumentSerializer

  SUPPORTED_RELATIONSHIPS = %w[documents person].freeze
end
