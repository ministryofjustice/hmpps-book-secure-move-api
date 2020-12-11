module Metrics
  module Moves
    class CountsByMoveTypeSupplier
      include BaseMetric

      METRIC = {
        label: 'Move counts by move type and supplier',
        file: 'moves/counts_by_move_type_supplier',
        interval: 5.minutes,
        columns: {
          name: 'move_type',
          field: :itself,
          values: Move.move_types.values,
        },
        rows: {
          name: 'supplier',
          field: :key,
          values: -> { Supplier.all + [nil] }, # NB: use lambda to delay evaluation until metric is used
        },
      }.freeze

      def initialize
        setup_metric(METRIC)
      end

      def calculate_row(row_supplier)
        Move
          .where(supplier: row_supplier)
          .group(:move_type)
          .count
      end
    end
  end
end
