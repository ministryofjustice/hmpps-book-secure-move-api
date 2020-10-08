module Metrics
  class MoveCountsStatusTotal
    include BaseMetric

    METRIC = {
      label: 'Move counts by status',
      file: 'moves/status_count',
      interval: 5.minutes,
      columns: {
        name: 'status',
        field: :itself,
        values: Move.statuses.values,
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

    def calculate(column_status, _row)
      Move
        .where(status: column_status)
        .count
    end
  end
end
