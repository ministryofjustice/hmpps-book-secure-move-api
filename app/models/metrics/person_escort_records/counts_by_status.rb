module Metrics
  module PersonEscortRecords
    class CountsByStatus
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by status',
          file: 'counts_by_status',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: PersonEscortRecord.statuses.values << TOTAL,
          },
          rows: {
            name: COUNT,
            field: :itself,
            values: [PERSON_ESCORT_RECORDS],
          },
        )
      end

      def calculate_row(_row)
        person_escort_records
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
