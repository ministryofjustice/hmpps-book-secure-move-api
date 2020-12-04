module Metrics
  module Moves
    class CountsBySupplier
      include BaseMetric

      METRIC = {
        label: 'Move counts by supplier',
        file: 'moves/counts_by_supplier',
        interval: 5.minutes,
        columns: {
          name: 'supplier',
          field: :key,
          values: -> { Supplier.all + [nil] }, # NB: use lambda to delay evaluation until metric is used
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

      def calculate(column_supplier, _row)
        Move
          .where(supplier: column_supplier)
          .count
      end
    end
  end
end
