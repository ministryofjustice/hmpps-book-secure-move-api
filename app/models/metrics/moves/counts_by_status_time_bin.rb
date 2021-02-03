module Metrics
  module Moves
    class CountsByStatusTimeBin
      include BaseMetric
      include Moves
      include TimeBins

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'Move counts by status and time bin',
          file: 'counts_by_status_time_bin',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values << TOTAL,
          },
          rows: {
            name: 'time',
            field: :title,
            values: COMMON_TIME_BINS,
          },
        )
      end

      def calculate_row(row_time_bin)
        apply_time_bin(moves, row_time_bin)
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
