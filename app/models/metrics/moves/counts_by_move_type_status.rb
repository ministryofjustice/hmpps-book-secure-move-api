module Metrics
  module Moves
    class CountsByMoveTypeStatus
      include BaseMetric

      METRIC = {
        label: 'Move counts by move type and status',
        file: 'moves/counts_by_move_type_status',
        interval: 5.minutes,
        columns: {
          name: 'move_type',
          field: :itself,
          values: Move.move_types.values,
        },
        rows: {
          name: 'status',
          field: :itself,
          values: Move.statuses.values,
        },
      }.freeze

      def initialize
        setup_metric(METRIC)
      end

      def calculate_row(row_status)
        Move
          .where(status: row_status)
          .group(:move_type)
          .count
      end
    end
  end
end
