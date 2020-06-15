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

  SUPPORTED_RELATIONSHIPS = %w[ethnicity gender].freeze

  def assessment_answers
    object.latest_profile&.assessment_answers || []
  end

  def identifiers
    [police_national_computer, prison_number, criminal_records_office].compact
  end

  def police_national_computer
    if object.police_national_computer.present?
      {
        value: object.police_national_computer,
        identifier_type: 'police_national_computer',
      }
    end
  end

  def prison_number
    if object.prison_number.present?
      {
        value: object.prison_number,
        identifier_type: 'prison_number',
      }
    end
  end

  def criminal_records_office
    if object.criminal_records_office.present?
      {
        value: object.criminal_records_office,
        identifier_type: 'criminal_records_office',
      }
    end
  end
end
