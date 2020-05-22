# frozen_string_literal: true

class ProfileSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :first_names,
    :last_name,
    :date_of_birth,
    :assessment_answers,
    :identifiers,
    :gender_additional_information,
  )

  has_one :ethnicity, serializer: EthnicitySerializer, if: -> { object.ethnicity.present? }
  has_one :gender, serializer: GenderSerializer

  SUPPORTED_RELATIONSHIPS = %i[ethnicity gender].freeze

  def assessment_answers
    object.assessment_answers || []
  end

  def identifiers
    object.profile_identifiers || []
  end
end
