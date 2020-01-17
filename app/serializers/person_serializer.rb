# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :first_names,
    :last_name,
    :date_of_birth,
    :assessment_answers,
    :identifiers,
    :gender_additional_information,
  )

  has_one :ethnicity, serializer: EthnicitySerializer
  has_one :gender, serializer: GenderSerializer

  INCLUDED_DETAIL = %i[ethnicity gender].freeze

  def first_names
    object.latest_profile&.first_names
  end

  def last_name
    object.latest_profile&.last_name
  end

  def date_of_birth
    object.latest_profile&.date_of_birth
  end

  def ethnicity
    object.latest_profile&.ethnicity
  end

  def gender
    object.latest_profile&.gender
  end

  def gender_additional_information
    object.latest_profile&.gender_additional_information
  end

  def assessment_answers
    object.latest_profile&.assessment_answers || []
  end

  def identifiers
    object.latest_profile&.profile_identifiers || []
  end
end
