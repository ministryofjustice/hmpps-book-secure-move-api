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
        date_of_birth: :date_of_birth
        # ethnicity_id: :ethnicity
        # gender_id: :gender
    }

    def initialize(prison_number)
      @prison_number = prison_number
    end

    def call
      #TODO: remove nomis_prison_nuber from person, prison_number is the used field
      NomisClient::People

      person = Person.find_by(prison_number: @prison_number)

      if person
        person.update(new_person_attributes.merge(last_synced_with_nomis: Time.now))
      else
        Person.create(
          new_person_attributes.merge(last_synced_with_nomis: Time.now)
        )
      end
    end

  private

    def new_person_attributes
      person_from_nomis.filter_map{ |k,v| [MAPPING[k], v] if MAPPING[k]}.to_h
    end

    def person_from_nomis
      NomisClient::People.get(Array(@prison_number))
                         .find { |p| p[:prison_number] == @prison_number }
    end
  end
end
