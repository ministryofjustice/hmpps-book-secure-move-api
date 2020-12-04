module Metrics
  module Moves
    class CountsByMoveType
      include BaseMetric

      METRIC = {
        label: 'Move counts by move type',
        file: 'moves/counts_by_move_type',
        interval: 5.minutes,
        columns: {
          name: 'move_type',
          field: :itself,
          values: Move.move_types.values,
        },
        rows: {
          name: 'total',
          field: :itself,
          values: %w[total],
        },
      }.freeze

      def initialize
        setup_metric(METRIC)
      end

      def calculate(column_move_type, _row)
        Move
          .where(move_type: column_move_type)
          .count
      end
    end
  end
end
