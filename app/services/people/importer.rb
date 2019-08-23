# frozen_string_literal: true

module People
  class Importer
    PROFILE_IDENTIFIERS_MAPPING = {
      'police_national_computer' => :pnc_number,
      'prison_number' => :prison_number,
      'criminal_records_office' => :cro_number
    }.freeze

    attr_accessor :nomis_attributes

    def initialize(nomis_attributes)
      self.nomis_attributes = nomis_attributes
    end

    def call
      person = Person.find_or_create_by(nomis_prison_number: nomis_attributes[:prison_number])
      profile = person.latest_profile || person.profiles.build
      profile.update(attributes)
    end

    private

    def attributes
      nomis_attributes.slice(:last_name, :date_of_birth, :aliases).merge(
        first_names: first_names,
        gender_id: Gender.find_by(nomis_code: nomis_attributes[:gender]).id,
        ethnicity_id: Ethnicity.find_by(title: nomis_attributes[:ethnicity]).id,
        profile_identifiers: profile_identifiers
      )
    end

    def first_names
      [nomis_attributes[:first_name], nomis_attributes[:middle_names]].compact.join(' ')
    end

    def profile_identifiers
      PROFILE_IDENTIFIERS_MAPPING.map do |local, nomis|
        { value: nomis_attributes[nomis], identifier_type: local } if nomis_attributes[nomis]
      end.compact
    end
  end
end
