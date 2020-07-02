# frozen_string_literal: true

module People
  class ImportFromNomis
    NOMIS_OFFENDER_TO_PERSON_MAPPING = {
      cro_number: :criminal_records_office,
      date_of_birth: :date_of_birth,
      first_name: :first_names,
      last_name: :last_name,
      latest_booking_id: :latest_nomis_booking_id,
      pnc_number: :police_national_computer,
      prison_number: :prison_number,
    }.freeze

    def initialize(prison_numbers)
      @prison_numbers = prison_numbers
    end

    def call
      @prison_numbers.each do |prison_number|
        person = Person.find_or_initialize_by(prison_number: prison_number)

        nomis_person = people_from_nomis.find do |nomis_person|
          nomis_person[:prison_number] == prison_number
        end

        next unless nomis_person

        person.assign_attributes(person_attributes(nomis_person))
        person.save!
      end
    end

  private

    def person_attributes(nomis_person)
      person_attributes = nomis_person.filter_map do |attribute, value|
        if NOMIS_OFFENDER_TO_PERSON_MAPPING[attribute]
          [NOMIS_OFFENDER_TO_PERSON_MAPPING[attribute], value]
        end
      end
      person_attributes = person_attributes.to_h

      person_attributes.merge(
        nomis_prison_number: person_attributes[:prison_number],
        last_synced_with_nomis: Time.zone.now,
        gender: gender(nomis_person),
        ethnicity: ethnicity(nomis_person),
      )
    end

    def people_from_nomis
      @people_from_nomis ||= NomisClient::People.get(@prison_numbers)
    end

    def gender(nomis_person)
      Gender.find_by(nomis_code: nomis_person[:gender])
    end

    def ethnicity(nomis_person)
      Ethnicity.find_by(title: nomis_person[:ethnicity])
    end
  end
end
