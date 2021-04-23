module Metrics
  module PersonEscortRecords
    class CountsByStatusMoveTimeBin
      include BaseMetric
      include PersonEscortRecords
      include TimeBins

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by status and move time bin',
          file: 'counts_by_status_move_time_bin',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: PersonEscortRecord.statuses.values << TOTAL,
          },
          rows: {
            name: 'time',
            field: :title,
            values: COMMON_TIME_BINS,
          },
        )
      end

      def calculate_row(row_time_bin)
        apply_time_bin(person_escort_records_with_moves, row_time_bin, field: 'moves.date')
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
