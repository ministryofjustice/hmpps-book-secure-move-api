module Metrics
  module Moves
    class CountsByTimeBin
      include BaseMetric
      include TimeBins

      METRIC = {
        label: 'Move counts by time bin',
        file: 'moves/counts_by_time_bin',
        interval: 5.minutes,
        columns: {
          name: 'total',
          field: :itself,
          values: %w[total],
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

      def calculate(_col, row_time_bin)
        apply_time_bin(Move, row_time_bin)
          .count
      end
    end
  end
end
