module Metrics
  module PersonEscortRecords
    class CountsByPerStatusMoveStatus
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier:,
          label: 'PER counts by PER status and move status',
          file: 'counts_by_per_status_move_status',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: PersonEscortRecord.statuses.keys << TOTAL,
          },
          rows: {
            name: 'move_status',
            field: :itself,
            values: Move.statuses.keys,
          },
        )
      end

      def calculate_row(row_move_status)
        person_escort_records_with_moves
          .where(moves: { status: row_move_status })
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
