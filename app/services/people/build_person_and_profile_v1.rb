# frozen_string_literal: true

module People
  # This class is "Legacy Code", only relevant to endpoint V1.
  # Its functionality have been refactored into:
  #   - People::Importer
  #   - Profile::ImportAlertsAndPersonalCareNeeds
  # Those are relevant to version >= V2
  #
  class BuildPersonAndProfileV1
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

      # TODO: This will get removed when we separate person/profile
      person.latest_profile || person.profiles.build
    end

  private

    attr_reader :nomis_attributes

    def person_attributes
      nomis_attributes.slice(:last_name, :date_of_birth).merge(
        first_names:,
        gender:,
        ethnicity:,
        police_national_computer:,
        prison_number:,
        criminal_records_office:,
        last_synced_with_nomis:,
        latest_nomis_booking_id:,
      )
    end

    def gender
      @gender ||= Gender.find_by(nomis_code: nomis_attributes[:gender])
    end

    def ethnicity
      @ethnicity ||= Ethnicity.find_by(title: nomis_attributes[:ethnicity])
    end

    def first_names
      @first_names ||= [nomis_attributes[:first_name], nomis_attributes[:middle_names]].compact.join(' ')
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

    def latest_nomis_booking_id
      nomis_attributes[:latest_booking_id]
    end

    def last_synced_with_nomis
      @last_synced_with_nomis ||= Time.zone.now
    end
  end
end
