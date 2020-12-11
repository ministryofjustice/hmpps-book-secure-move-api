module Metrics
  module Moves
    class CountsByStatusTimeBin
      include BaseMetric
      include TimeBins

      METRIC = {
        label: 'Move counts by status and time bin',
        file: 'moves/counts_by_status_time_bin',
        interval: 5.minutes,
        columns: {
          name: 'status',
          field: :itself,
          values: Move.statuses.values,
        },
        rows: {
          name: 'time',
          field: :title,
          values: COMMON_TIME_BINS,
        },
      }.freeze

      def initialize
        setup_metric(METRIC)
      end

      def calculate_row(row_time_bin)
        apply_time_bin(Move, row_time_bin)
          .group(:status)
          .count
      end
    end
  end
end
