module Metrics
  module PersonEscortRecords
    class CountsByMoveTimeBin
      include BaseMetric
      include PersonEscortRecords
      include TimeBins

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by move time bin',
          file: 'counts_by_move_time_bin',
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
        apply_time_bin(person_escort_records_with_moves, row_time_bin, field: 'moves.date')
          .count
      end
    end
  end
end
