# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class MoveCollector < PrometheusExporter::Server::TypeCollector
  include PrometheusExporter::Metric

  def type
    'move'
  end

  def metrics
    # All moves in any status
    move_count = PrometheusExporter::Metric::Counter.new('move_count', 'Number of moves in the system')
    move_count.observe(Move.count)

    # Moves by status
    move_count_proposed = PrometheusExporter::Metric::Counter.new('move_count_proposed', 'Number of proposed moves in the system')
    move_count_proposed.observe(Move.where(status: Move::MOVE_STATUS_PROPOSED).count)

    move_count_requested = PrometheusExporter::Metric::Counter.new('move_count_requested', 'Number of requested moves in the system')
    move_count_requested.observe(Move.where(status: Move::MOVE_STATUS_REQUESTED).count)

    move_count_booked = PrometheusExporter::Metric::Counter.new('move_count_booked', 'Number of booked moves in the system')
    move_count_booked.observe(Move.where(status: Move::MOVE_STATUS_BOOKED).count)

    move_count_in_transit = PrometheusExporter::Metric::Counter.new('move_count_in_transit', 'Number of in_transit moves in the system')
    move_count_in_transit.observe(Move.where(status: Move::MOVE_STATUS_IN_TRANSIT).count)

    move_count_completed = PrometheusExporter::Metric::Counter.new('move_count_completed', 'Number of completed moves in the system')
    move_count_completed.observe(Move.where(status: Move::MOVE_STATUS_COMPLETED).count)

    move_count_cancelled = PrometheusExporter::Metric::Counter.new('move_count_cancelled', 'Number of cancelled moves in the system')
    move_count_cancelled.observe(Move.where(status: Move::MOVE_STATUS_CANCELLED).count)

    # Moves which are not cancelled scheduled for specific date ranges
    move_count_today_not_cancelled = PrometheusExporter::Metric::Counter.new('move_count_today_not_cancelled', 'Number of moves in the system which were scheduled for today and were not cancelled')
    move_count_today_not_cancelled.observe(Move.not_cancelled.where(date: Time.zone.today).count)

    move_count_past_7_days_not_cancelled = PrometheusExporter::Metric::Counter.new('move_count_past_7_days_not_cancelled', 'Number of moves in the system which were scheduled for the past 7 days and were not cancelled')
    move_count_past_7_days_not_cancelled.observe(Move.not_cancelled.where(date: (Time.zone.today - 6)..Time.zone.today).count)

    move_count_past_30_days_not_cancelled = PrometheusExporter::Metric::Counter.new('move_count_past_30_days_not_cancelled', 'Number of moves in the system which were scheduled for the past 30 days and were not cancelled')
    move_count_past_30_days_not_cancelled.observe(Move.not_cancelled.where(date: (Time.zone.today - 29)..Time.zone.today).count)

    move_count_tomorrow_not_cancelled = PrometheusExporter::Metric::Counter.new('move_count_tomorrow_not_cancelled', 'Number of moves in the system which are scheduled for tomorrow and are not cancelled')
    move_count_tomorrow_not_cancelled.observe(Move.not_cancelled.where(date: Time.zone.tomorrow).count)

    move_count_next_7_days_not_cancelled = PrometheusExporter::Metric::Counter.new('move_count_next_7_days_not_cancelled', 'Number of moves in the system which are scheduled for the next 7 days and are not cancelled')
    move_count_next_7_days_not_cancelled.observe(Move.not_cancelled.where(date: Time.zone.today..(Time.zone.today + 6)).count)

    move_count_next_30_days_not_cancelled = PrometheusExporter::Metric::Counter.new('move_count_next_30_days_not_cancelled', 'Number of moves in the system which are scheduled for the next 30 days and are not cancelled')
    move_count_next_30_days_not_cancelled.observe(Move.not_cancelled.where(date: Time.zone.today..(Time.zone.today + 29)).count)

    [move_count,
     move_count_proposed,
     move_count_requested,
     move_count_booked,
     move_count_in_transit,
     move_count_completed,
     move_count_cancelled,
     move_count_today_not_cancelled,
     move_count_past_7_days_not_cancelled,
     move_count_past_30_days_not_cancelled,
     move_count_tomorrow_not_cancelled,
     move_count_next_7_days_not_cancelled,
     move_count_next_30_days_not_cancelled]
  end
end
