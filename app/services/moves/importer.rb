# frozen_string_literal: true

module Moves
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      items.each do |move|
        import_person(move[:person_nomis_prison_number])
        import_alerts(move[:person_nomis_prison_number])
        import_personal_care_needs(move[:person_nomis_prison_number])
        import_move(move)
      end
    end

    private

    def import_person(prison_number)
      person_attributes = NomisClient::People.get(prison_number)
      People::Importer.new(person_attributes).call
    end

    def import_alerts(prison_number)
      person = Person.find_by(nomis_prison_number: prison_number)
      alerts = NomisClient::Alerts.get(prison_number)
      Alerts::Importer.new(profile: person.latest_profile, alerts: alerts).call
    end

    def import_personal_care_needs(prison_number)
      person = Person.find_by(nomis_prison_number: prison_number)
      personal_care_needs = NomisClient::PersonalCareNeeds.get(
        person.latest_profile&.latest_nomis_booking_id
      )
      PersonalCareNeeds::Importer.new(
        profile: person.latest_profile,
        personal_care_needs: personal_care_needs
      ).call
    end

    def import_move(move)
      Move
        .find_or_initialize_by(nomis_event_id: move[:nomis_event_id])
        .update(move_params(move))
    end

    def move_params(move)
      move.slice(:date, :time_due, :status).merge(
        person: Person.find_by(nomis_prison_number: move[:person_nomis_prison_number]),
        from_location: Location.find_by(nomis_agency_id: move[:from_location_nomis_agency_id]),
        to_location: Location.find_by(nomis_agency_id: move[:to_location_nomis_agency_id])
      )
    end
  end
end
