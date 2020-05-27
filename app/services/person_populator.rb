class PersonPopulator
  def initialize(person, profile)
    @person = person
    @profile = profile
  end

  def call
    populate_standard_attributes
    populate_identifier_attributes
    person.save
  end

private

  attr_reader :person, :profile

  STANDARD_ATTRIBUTES = %w[
    first_names
    last_name
    date_of_birth
    gender_additional_information
    latest_nomis_booking_id
    ethnicity_id
    gender_id
  ].freeze

  IDENTIFIER_ATTRIBUTES = %w[
    prison_number
    criminal_records_office
    police_national_computer
  ].freeze

  def populate_standard_attributes
    attributes = profile.attributes.slice(*STANDARD_ATTRIBUTES)

    person.assign_attributes(attributes)
  end

  def populate_identifier_attributes
    attributes = profile.profile_identifiers.each_with_object({}) do |identifier, acc|
      acc[identifier.identifier_type] = identifier.value
    end
    attributes = attributes.slice(*IDENTIFIER_ATTRIBUTES)

    person.assign_attributes(attributes)
  end
end
