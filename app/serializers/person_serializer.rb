# frozen_string_literal: true

class PersonSerializer
  include JSONAPI::Serializer

  set_type :people

  attributes(
    :first_names,
    :last_name,
    :date_of_birth,
    :assessment_answers,
    :identifiers,
    :gender_additional_information,
  )

  attribute :assessment_answers do |object|
    object.latest_profile&.assessment_answers || []
  end

  attribute :identifiers do |object|
    %i[police_national_computer prison_number criminal_records_office].each_with_object([]) do |identifier, array|
      next if object.public_send(identifier).blank?

      array << {
        value: object.public_send(identifier),
        identifier_type: identifier.to_s,
      }
    end
  end

  has_one :ethnicity
  has_one :gender

  SUPPORTED_RELATIONSHIPS = %w[ethnicity gender].freeze
end
