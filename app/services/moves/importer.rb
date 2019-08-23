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
        import_move(move)
      end
    end

    private

    def import_person(prison_number)
      person_attributes = NomisClient::People.get(prison_number)
      People::Importer.new(person_attributes).call
    end

    def import_move(move)
      Move
        .find_or_initialize_by(nomis_event_id: move[:nomis_event_id])
        .update(move_params(move))
    end

    def move_params(move)
      move.slice(:date, :time_due).merge(
        person: Person.find_by(nomis_prison_number: move[:person_nomis_prison_number]),
        from_location: Location.find_by(nomis_agency_id: move[:from_location_nomis_agency_id]),
        to_location: Location.find_by(nomis_agency_id: move[:to_location_nomis_agency_id])
      )
    end
  end
end
