module Metrics
  module Moves
    class CountsByMoveTypeTimeBin
      include BaseMetric
      include TimeBins

      METRIC = {
        label: 'Move counts by move type and time bin',
        file: 'moves/counts_by_move_type_time_bin',
        interval: 5.minutes,
        columns: {
          name: 'move_type',
          field: :itself,
          values: Move.move_types.values,
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
          .group(:move_type)
          .count
      end
    end
  end
end
