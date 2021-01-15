module Metrics
  module Moves
    class CountsBySupplier
      include BaseMetric
      include Moves

      def initialize
        setup_metric(
          label: 'Move counts by supplier',
          file: "#{database}/counts_by_supplier",
          interval: 5.minutes,
          columns: {
            name: COUNT,
            field: :itself,
            values: [COUNT],
          },
          rows: {
            name: COUNT,
            field: :key,
            values: -> { Supplier.all + [nil] }, # NB: use lambda to delay evaluation until metric is used
          },
        )
      end

      def calculate(_col, row_supplier)
        moves
          .where(supplier: row_supplier)
          .count
      end
    end
  end
end
