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

  # although we are serialising a 'profile', to the outside world this is a person.
  type 'people'

  has_one :ethnicity, serializer: EthnicitySerializer
  has_one :gender, serializer: GenderSerializer

  INCLUDED_DETAIL = %i[ethnicity gender].freeze

  def id
    object.person.id
  end

  def identifiers
    object.profile_identifiers
  end
end
