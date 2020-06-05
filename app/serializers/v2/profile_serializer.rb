# frozen_string_literal: true

module V2
  class ProfileSerializer < ActiveModel::Serializer
    attributes(
      :assessment_answers,
    )

    belongs_to :person, serializer: PersonSerializer

    SUPPORTED_RELATIONSHIPS = %w[person].freeze
  end
end
