# frozen_string_literal: true

module People
  class ImportFromNomis
    PRISONER_SEARCH_TO_PERSON_MAPPING = {
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
        prisoner_search_person = PrisonerSearchApiClient::Prisoner.get(prison_number: prison_number)
        next unless prisoner_search_person

        person = Person.find_or_initialize_by(prison_number:)
        attributes = person_attributes(prisoner_search_person)
        person.assign_attributes(attributes)
        person.save!
      end
    end

  private

    def person_attributes(prisoner_search_person)
      person_attributes = prisoner_search_person.filter_map do |attribute, value|
        if PRISONER_SEARCH_TO_PERSON_MAPPING[attribute]
          [PRISONER_SEARCH_TO_PERSON_MAPPING[attribute], value]
        end
      end
      person_attributes = person_attributes.to_h
      person_attributes.merge(
        nomis_prison_number: person_attributes[:prison_number],
        last_synced_with_nomis: Time.zone.now,
        gender: gender(prisoner_search_person),
        ethnicity: ethnicity(prisoner_search_person),
      )
    end

    def gender(prisoner_search_person)
      Gender.find_by(title: prisoner_search_person[:gender])
    end

    def ethnicity(prisoner_search_person)
      Ethnicity.find_by(title: prisoner_search_person[:ethnicity])
    end
  end
end
