module Metrics
  module Moves
    class CountsByTimeBin
      include BaseMetric
      include TimeBins

      METRIC = {
        label: 'Move counts by time bin',
        file: 'moves/counts_by_time_bin',
        interval: 5.minutes,
        columns: {
          name: 'time',
          field: :title,
          values: COMMON_TIME_BINS,
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

      def calculate(column_time_bin, _row)
        moves = Move
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
