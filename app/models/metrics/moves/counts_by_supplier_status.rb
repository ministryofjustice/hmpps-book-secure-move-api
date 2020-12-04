module Metrics
  module Moves
    class CountsBySupplierStatus
      include BaseMetric

      METRIC = {
        label: 'Move counts by supplier and status',
        file: 'moves/counts_by_supplier_status',
        interval: 5.minutes,
        columns: {
          name: 'supplier',
          field: :key,
          values: -> { Supplier.all + [nil] }, # NB: use lambda to delay evaluation until metric is used
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

      def calculate(column_supplier, row_status)
        Move
          .where(supplier: column_supplier)
          .where(status: row_status)
          .count
      end
    end
  end
end
