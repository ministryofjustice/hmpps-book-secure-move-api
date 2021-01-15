module Metrics
  module Moves
    class CountsByMoveType
      include BaseMetric
      include Moves

      def initialize
        setup_metric(
          label: 'Move counts by move type',
          file: "#{database}/counts_by_move_type",
          interval: 5.minutes,
          columns: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values << TOTAL,
          },
          rows: {
            name: COUNT,
            field: :itself,
            values: [COUNT],
          },
        )
      end

      def calculate_row(_row)
        moves
          .group(:move_type)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
