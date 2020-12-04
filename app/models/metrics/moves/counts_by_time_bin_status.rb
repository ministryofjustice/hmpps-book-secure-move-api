module Metrics
  module Moves
    class CountsByTimeBinStatus
      include BaseMetric
      include TimeBins

      METRIC = {
        label: 'Move counts by time bin and status',
        file: 'moves/counts_by_time_bin_status',
        interval: 5.minutes,
        columns: {
          name: 'time',
          field: :title,
          values: COMMON_TIME_BINS,
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

      def calculate(column_time_bin, row_status)
        moves = Move.where(status: row_status)
        if column_time_bin.date_from_offset.present? && column_time_bin.date_to_offset.present? && column_time_bin.date_from_offset == column_time_bin.date_to_offset
          moves = moves.where(date: Time.zone.now + column_time_bin.date_from_offset.days)
        else
          moves = moves.where('date >= ?', Time.zone.today + column_time_bin.date_from_offset.days) if column_time_bin.date_from_offset.present?
          moves = moves.where('date <= ?', Time.zone.today + column_time_bin.date_to_offset.days) if column_time_bin.date_to_offset.present?
        end
        moves.count
      end
    end
  end
end
