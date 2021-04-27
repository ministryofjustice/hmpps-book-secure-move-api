module Metrics
  module PersonEscortRecords
    class CountsByPerStatus
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by PER status',
          file: 'counts_by_per_status',
          interval: 5.minutes,
          columns: {
            name: 'status',
            field: :itself,
            values: PersonEscortRecord.statuses.keys << TOTAL,
          },
          rows: {
            name: COUNT,
            field: :itself,
            values: [PERSON_ESCORT_RECORDS],
          },
        )
      end

      def calculate_row(_row)
        person_escort_records_with_moves
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
