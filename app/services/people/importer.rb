# frozen_string_literal: true

module People
  class Importer
    NOMIS_IDENTIFIER_MAPPING = {
      'police_national_computer' => :pnc_number,
      'prison_number' => :prison_number,
      'criminal_records_office' => :cro_number,
    }.freeze

    def initialize(nomis_attributes)
      @nomis_attributes = nomis_attributes
    end

    def call
      person = Person.find_or_initialize_by(nomis_prison_number: nomis_attributes[:prison_number])
      person.assign_attributes(person_attributes)

      profile = person.latest_profile || person.profiles.build
      profile.assign_attributes(profile_attributes)

      profile
    end

  private

    attr_reader :nomis_attributes

    def person_attributes
      nomis_attributes.slice(:last_name, :date_of_birth).merge(
        first_names: first_names,
        gender: gender,
        ethnicity: ethnicity,
        police_national_computer: police_national_computer,
        prison_number: prison_number,
        criminal_records_office: criminal_records_office,
        last_synced_with_nomis: last_synced_with_nomis,
      )
    end

    def profile_attributes
      nomis_attributes.slice(:last_name, :date_of_birth, :aliases).merge(
        first_names: first_names,
        gender: gender,
        ethnicity: ethnicity,
        profile_identifiers: profile_identifiers,
        latest_nomis_booking_id: latest_nomis_booking_id,
        last_synced_with_nomis: last_synced_with_nomis,
      )
    end

    def gender
      Gender.find_by(nomis_code: nomis_attributes[:gender])
    end

    def ethnicity
      Ethnicity.find_by(title: nomis_attributes[:ethnicity])
    end

    def first_names
      [nomis_attributes[:first_name], nomis_attributes[:middle_names]].compact.join(' ')
    end

    def police_national_computer
      nomis_attributes[NOMIS_IDENTIFIER_MAPPING['police_national_computer']]
    end

    def prison_number
      nomis_attributes[NOMIS_IDENTIFIER_MAPPING['prison_number']]
    end

    def criminal_records_office
      nomis_attributes[NOMIS_IDENTIFIER_MAPPING['criminal_records_office']]
    end

    def profile_identifiers
      NOMIS_IDENTIFIER_MAPPING.map { |local, nomis|
        { value: nomis_attributes[nomis], identifier_type: local } if nomis_attributes[nomis]
      }.compact
    end

    def latest_nomis_booking_id
      nomis_attributes[:latest_booking_id]
    end

    def last_synced_with_nomis
      @last_synced_with_nomis ||= Time.zone.now
    end
  end
end
