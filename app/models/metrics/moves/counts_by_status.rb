module Metrics
  module Moves
    class CountsByStatus
      include BaseMetric

      METRIC = {
        label: 'Move counts by status',
        file: 'moves/counts_by_status',
        interval: 5.minutes,
        columns: {
          name: 'status',
          field: :itself,
          values: Move.statuses.values,
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

      def calculate_row(_row)
        Move
          .group(:status)
          .count
      end
    end
  end
end
