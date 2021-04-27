module Metrics
  module PersonEscortRecords
    class CountsByPerStatusMoveType
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by PER status and move type',
          file: 'counts_by_per_status_move_type',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: PersonEscortRecord.statuses.keys << TOTAL,
          },
          rows: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values,
          },
        )
      end

      def calculate_row(row_move_type)
        person_escort_records_with_moves
          .where(moves: { move_type: row_move_type })
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
