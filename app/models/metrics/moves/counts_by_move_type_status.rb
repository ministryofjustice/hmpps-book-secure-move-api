module Metrics
  module Moves
    class CountsByMoveTypeStatus
      include BaseMetric
      include Moves

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'Move counts by move type and status',
          file: 'counts_by_move_type_status',
          interval: 5.minutes,
          columns: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values << TOTAL,
          },
          rows: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values,
          },
        )
      end

      def calculate_row(row_status)
        moves
          .where(status: row_status)
          .group(:move_type)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
