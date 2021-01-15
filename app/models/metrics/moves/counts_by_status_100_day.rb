module Metrics
  module Moves
    class CountsByStatus100Day
      include BaseMetric
      include Moves

      def initialize
        setup_metric(
          label: 'Move counts by status for past 100 days',
          file: "#{database}/counts_by_status_100_day",
          interval: 6.hours, # we don't need to re-calculate this report very often (and it takes a while to calculate)
          columns: {
            name: 'status',
            field: :itself,
            values: Move.statuses.values << TOTAL,
          },
          rows: {
            name: 'date',
            field: :iso8601,
            values: -> { ((Time.zone.today - 100.days)..(Time.zone.yesterday)).to_a.reverse },
          },
        )
      end

      def calculate_row(row_date)
        moves
          .where(date: row_date)
          .group(:status)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
