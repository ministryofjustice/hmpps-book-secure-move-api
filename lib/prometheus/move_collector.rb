# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class MoveCollector < PrometheusExporter::Server::TypeCollector
  include PrometheusExporter::Metric

  def type
    'move'
  end

  def metrics
    metric = PrometheusExporter::Metric::Gauge.new('move_gauge', 'Number of moves in the system')

    statuses = [nil] + Move.statuses.values
    suppliers = [nil] + Supplier.all

    statuses.each do |status|
      suppliers.each do |supplier|
        observe_moves_count_buckets(metric, status: status, supplier: supplier)
      end
    end

    [metric]
  end

private

  def observe_moves_count_buckets(metric, status: nil, supplier: nil)
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: nil, date_to_offset: nil) # all time
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: nil, date_to_offset: 0) # the past
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: -29, date_to_offset: 0) # the past 30 days
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: -6, date_to_offset: 0) # the past week
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: -1, date_to_offset: -1) # yesterday
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: 0, date_to_offset: 0) # today
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: 1, date_to_offset: 1) # tomorrow
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: 0, date_to_offset: 6) # the next 7 days
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: 0, date_to_offset: 29) # the next 30 days
    observe_moves_count(metric, status: status, supplier: supplier, date_from_offset: 0, date_to_offset: nil) # the future
  end

  def observe_moves_count(metric, status: nil, supplier: nil, date_from_offset: nil, date_to_offset: nil)
    moves = Move
    moves = moves.where(supplier: supplier) if supplier.present?
    moves = moves.where(status: status) if status.present?
    if date_from_offset.present? && date_to_offset.present? && date_from_offset == date_to_offset
      moves = moves.where(date: Time.zone.now + date_from_offset.days)
    else
      moves = moves.where('date >= ?', Time.zone.today + date_from_offset.days) if date_from_offset.present?
      moves = moves.where('date <= ?', Time.zone.today + date_to_offset.days) if date_to_offset.present?
    end
    metric.observe(moves.count, status: status || '*', supplier: supplier&.key || '*', date_from_offset: date_from_offset || '*', date_to_offset: date_to_offset || '*')
  end
end
