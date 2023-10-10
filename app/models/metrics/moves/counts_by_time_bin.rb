module Metrics
  module Moves
    class CountsByTimeBin
      include BaseMetric
      include Moves
      include TimeBins

      def initialize(supplier: nil)
        setup_metric(
          supplier:,
          label: 'Move counts by time bin',
          file: 'counts_by_time_bin',
          interval: 5.minutes,
          columns: {
            name: COUNT,
            field: :itself,
            values: [COUNT],
          },
          rows: {
            name: TIME,
            field: :title,
            values: COMMON_TIME_BINS,
          },
        )
      end

      def calculate(_col, row_time_bin)
        apply_time_bin(moves, row_time_bin)
          .count
      end
    end
  end
end
