module Metrics
  module Moves
    class CountsByStatusSupplier
      include BaseMetric
      include Moves

      def initialize
        setup_metric(
          label: 'Move counts by status and supplier',
          file: 'moves/counts_by_status_supplier',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values << TOTAL,
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
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
