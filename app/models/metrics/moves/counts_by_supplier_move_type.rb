module Metrics
  module Moves
    class CountsBySupplierMoveType
      include BaseMetric

      METRIC = {
        label: 'Move counts by supplier and move type',
        file: 'moves/counts_by_supplier_move_type',
        interval: 5.minutes,
        columns: {
          name: 'supplier',
          field: :key,
          values: -> { Supplier.all + [nil] }, # NB: use lambda to delay evaluation until metric is used
        },
        rows: {
          name: 'move_type',
          field: :itself,
          values: Move.move_types.values,
        },
      }.freeze

      def initialize
        setup_metric(METRIC)
      end

      def calculate(column_supplier, row_move_type)
        Move
          .where(supplier: column_supplier)
          .where(move_type: row_move_type)
          .count
      end
    end
  end
end
