# frozen_string_literal: true

module Moves
  class Sweeper
    attr_accessor :items, :date, :locations

    def initialize(locations, date, items)
      self.locations = locations
      self.date = date
      self.items = items
    end

    def call
      cancel_outdated_moves!
    end

    private

    def cancel_outdated_moves!
      update_nomis_event_ids!
      Move.where(
        date: date,
        from_location_id: locations.map(&:id),
        nomis_event_ids: []
      ).update(status: Move::MOVE_STATUS_CANCELLED)
    end

    def current_nomis_event_ids
      items.map { |item| item[:nomis_event_id] }
    end

    def update_nomis_event_ids!
      return if current_nomis_event_ids.empty?

      scope = Move.where(
        date: date,
        from_location_id: locations.map(&:id)
      )
      update_nomis_event_ids_containing_currents(scope)
      update_nomis_event_ids_not_containing_currents(scope)
    end

    def update_nomis_event_ids_containing_currents(scope)
      scope.where(
        'ARRAY[?] && nomis_event_ids', current_nomis_event_ids
      ).each do |move|
        move.update(nomis_event_ids: move.nomis_event_ids & current_nomis_event_ids)
      end
    end

    def update_nomis_event_ids_not_containing_currents(scope)
      scope.where.not(
        'ARRAY[?] && nomis_event_ids', current_nomis_event_ids
      ).each do |move|
        move.update(nomis_event_ids: [])
      end
    end
  end
end
