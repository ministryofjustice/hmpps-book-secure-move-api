module Metrics
  module Moves
    class CountsByStatusTimeBin
      include BaseMetric
      include TimeBins

      METRIC = {
        label: 'Move counts by time bin and status',
        file: 'moves/counts_by_time_bin_status',
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
