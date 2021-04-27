module Metrics
  module PersonEscortRecords
    class CountsByMoveType
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by move type',
          file: 'counts_by_move_type',
          interval: 5.minutes,
          columns: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values << TOTAL,
          },
          rows: {
            name: COUNT,
            field: :itself,
            values: [PERSON_ESCORT_RECORDS],
          },
        )
      end

      def calculate_row(_row)
        person_escort_records_with_moves
          .group(:move_type)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
