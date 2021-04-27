module Metrics
  module PersonEscortRecords
    class CountsByPerStatus100Day
      include BaseMetric
      include PersonEscortRecords

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'PER counts by PER status for past 100 days',
          file: 'counts_by_per_status_100_day',
          interval: 1.hour, # we don't need to re-calculate this report very often as it concerns old data
          columns: {
            name: 'status',
            field: :itself,
            values: PersonEscortRecord.statuses.keys << TOTAL,
          },
          rows: {
            name: 'date',
            field: :iso8601,
            values: -> { ((Time.zone.today - 100.days)..(Time.zone.yesterday)).to_a.reverse },
          },
        )
      end

      def calculate_table
        raw_data = person_escort_records_with_moves
          .where(moves: { date: (Time.zone.today - 100.days)..Time.zone.yesterday })
          .group(:date, :status)
          .count
        raw_data.default = 0

        transformed_data = ActiveSupport::HashWithIndifferentAccess.new(0)

        rows.each do |row|
          total = 0
          columns.each do |column|
            next if column == TOTAL

            transformed_data[value_key(column, row)] = raw_data[[row, column]]
            total += raw_data[[row, column]]
          end
          transformed_data[value_key(TOTAL, row)] = total
        end

        transformed_data
      end
    end
  end
end
