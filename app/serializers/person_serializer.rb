# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :first_names,
    :last_name,
    :date_of_birth,
    :assessment_answers,
    :identifiers
  )

  has_one :ethnicity, serializer: EthnicitySerializer
  has_one :gender, serializer: GenderSerializer

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

  def assessment_answers
    object.latest_profile&.assessment_answers || []
  end

  def identifiers
    object.latest_profile&.profile_identifiers || []
  end
end
