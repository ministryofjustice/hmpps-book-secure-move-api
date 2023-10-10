module Metrics
  module Moves
    class CountsByStatus
      include BaseMetric
      include Moves

      def initialize(supplier: nil)
        setup_metric(
          supplier:,
          label: 'Move counts by status',
          file: 'counts_by_status',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values << TOTAL,
          },
          rows: {
            name: COUNT,
            field: :itself,
            values: [MOVES],
          },
        )
      end

      def calculate_row(_row)
        moves
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
