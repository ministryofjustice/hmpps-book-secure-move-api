# frozen_string_literal: true

module People
  class ImportFromNomis
    MAPPING = {
      prison_number: :prison_number,
      first_name: :first_names,
      last_name: :last_name,
      criminal_records_office: :cro_number,
      police_national_computer: :pnc_number,
      latest_nomis_booking_id: :latest_booking_id,
      date_of_birth: :date_of_birth,
    }.freeze

    def initialize(prison_number)
      @prison_number = prison_number
    end

    def call
      person = Person.find_or_create_by(prison_number: @prison_number)
      person.assign_attributes(person_attributes)
      person.save!
    end

  private

    def person_attributes
      person_attributes = person_from_nomis.filter_map { |attribute, value|
        [MAPPING[attribute], value] if MAPPING[attribute]
      }.to_h

      person_attributes.merge(
        nomis_prison_number: @prison_number,
        last_synced_with_nomis: Time.zone.now,
        gender: gender,
        ethnicity: ethnicity,
      )
    end

    def person_from_nomis
      @person_from_nomis ||= NomisClient::People
          .get([@prison_number])
          .find { |p| p[:prison_number] == @prison_number }
    end

    def gender
      Gender.find_by(nomis_code: person_from_nomis[:gender])
    end

    def ethnicity
      Ethnicity.find_by(title: person_from_nomis[:ethnicity])
    end
  end
end
