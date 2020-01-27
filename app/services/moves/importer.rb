# frozen_string_literal: true

module Moves
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      Moves::ImportPeople.new(items).call

      import_moves
    end

  private

    def import_moves
      new_count = 0
      update_count = 0
      items.map { |m| move_params(m) }.each do |move|
        person = Person.find_by!(nomis_prison_number: move.fetch(:person_nomis_prison_number))
        new_move = person.latest_profile.moves.build(move.except(:person_nomis_prison_number))
        existing_move = Move.find_by(nomis_event_ids: [move[:nomis_event_id]]) || new_move.existing
        if existing_move
          existing_move.assign_attributes(move.except(:person_nomis_prison_number))
          if existing_move.changed?
            update_count += 1
            existing_move.save!
          end
        else
          new_count += 1
          new_move.save!
        end
      end
      if new_count.positive? || update_count.positive?
        Rails.logger.info("[Moves::Importer] moves new[#{new_count}]  updated[#{update_count}]")
      end
    end

    def move_params(move)
      move.slice(:date, :time_due, :status, :nomis_event_id, :person_nomis_prison_number).merge(
        from_location: Location.find_by(nomis_agency_id: move[:from_location_nomis_agency_id]),
        to_location: Location.find_by(nomis_agency_id: move[:to_location_nomis_agency_id]),
        move_agreed: false,
      )
    end
  end
end
