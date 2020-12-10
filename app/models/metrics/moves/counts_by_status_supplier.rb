module Metrics
  module Moves
    class CountsByStatusSupplier
      include BaseMetric

      METRIC = {
        label: 'Move counts by status and supplier',
        file: 'moves/counts_by_status_supplier',
        interval: 5.minutes,
        columns: {
          name: 'status',
          field: :itself,
          values: Move.statuses.values,
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
          .group(:status)
          .count
      end
    end
  end
end
