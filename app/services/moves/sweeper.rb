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
      cancel_duplicated_moves!
    end

    private

    def cancel_outdated_moves!
      outdated_moves = Move.where(
        date: date,
        from_location_id: locations.map(&:id)
      ).where.not(
        nomis_event_id: current_nomis_event_ids
      )
      outdated_moves.update(status: Move::MOVE_STATUS_CANCELLED)
    end

    def cancel_duplicated_moves!
      duplicated.size.map do |duplicate, _|
        Move.where(
          nomis_event_id: duplicate
        ).order(
          created_at: :desc
        ).offset(1).update(status: Move::MOVE_STATUS_CANCELLED)
      end
    end

    def current_nomis_event_ids
      items.map { |item| item[:nomis_event_id] }
    end

    def duplicated
      Move.select(
        :nomis_event_id
      ).where(
        nomis_event_id: current_nomis_event_ids
      ).group(
        :nomis_event_id
      ).having('count(*) > 1')
    end
  end
end
