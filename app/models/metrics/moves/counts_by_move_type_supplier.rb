module Metrics
  module Moves
    class CountsByMoveTypeSupplier
      include BaseMetric
      include Moves

      def initialize
        setup_metric(
          label: 'Move counts by move type and supplier',
          file: "#{database}/counts_by_move_type_supplier",
          interval: 5.minutes,
          columns: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values << TOTAL,
          },
          rows: {
            name: 'supplier',
            field: :key,
            values: -> { Supplier.all + [nil] }, # NB: use lambda to delay evaluation until metric is used
          },
        )
      end

      def calculate_row(row_supplier)
        moves
          .where(supplier: row_supplier)
          .group(:move_type)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
