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

    def import_move(attributes)
      move = Move.find_or_initialize_by(nomis_event_id: attributes[:nomis_event_id])
      move.update(move_params(attributes))
      cancel_duplicate_moves(move)
    end

    def cancel_duplicate_moves(move)
      duplicate_moves = Move.where(
        date: move.date,
        from_location_id: move.from_location_id,
        to_location_id: move.to_location_id,
        person_id: move.person_id
      ).where.not(
        id: move.id
      )
      duplicate_moves.update(status: Move::MOVE_STATUS_CANCELLED)
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
