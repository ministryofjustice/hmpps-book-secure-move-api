# frozen_string_literal: true

module People
  class Importer
    PROFILE_IDENTIFIERS_MAPPING = {
      'police_national_computer' => :pnc_number,
      'prison_number' => :prison_number,
      'criminal_records_office' => :cro_number,
    }.freeze

    attr_accessor :nomis_attributes

    def initialize(nomis_attributes)
      self.nomis_attributes = nomis_attributes
    end

    def call
      person = Person.find_or_create_by!(nomis_prison_number: nomis_attributes[:prison_number])
      profile = person.latest_profile || person.profiles.build
      profile.update(attributes)
    end

    private

    def attributes
      nomis_attributes.slice(:last_name, :date_of_birth, :aliases).merge(
        first_names: first_names,
        gender_id: find_gender,
        ethnicity_id: find_ethnicity,
        profile_identifiers: profile_identifiers,
        latest_nomis_booking_id: latest_nomis_booking_id,
      )
    end

    def find_gender
      gender_param = nomis_attributes[:gender]
      gender_param ? Gender.find_by(nomis_code: gender_param).id : nil
    end

    def find_ethnicity
      ethnicity_param = nomis_attributes[:ethnicity]
      ethnicity_param ? Ethnicity.find_by(title: ethnicity_param).id : nil
    end

    def first_names
      [nomis_attributes[:first_name], nomis_attributes[:middle_names]].compact.join(' ')
    end

    def profile_identifiers
      PROFILE_IDENTIFIERS_MAPPING.map do |local, nomis|
        { value: nomis_attributes[nomis], identifier_type: local } if nomis_attributes[nomis]
      end.compact
    end

    def latest_nomis_booking_id
      nomis_attributes[:latest_booking_id]
    end
  end
end
