module Metrics
  module PersonEscortRecords
    class CountsByMoveTypeMoveStatus
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by move type and move status',
          file: 'counts_by_move_type_move_status',
          interval: 5.minutes,
          columns: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values << TOTAL,
          },
          rows: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values,
          },
        )
      end

      def calculate_row(row_move_status)
        person_escort_records_with_moves
          .where(moves: { status: row_move_status })
          .group(:move_type)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
