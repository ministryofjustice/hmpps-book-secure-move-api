module Metrics
  module PersonEscortRecords
    class CountsByMoveStatus
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier:,
          label: 'PER counts by move status',
          file: 'counts_by_move_status',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values << TOTAL,
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
          .group('moves.status')
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
