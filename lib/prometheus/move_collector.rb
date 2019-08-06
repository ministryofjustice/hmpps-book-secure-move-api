# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class MoveCollector < PrometheusExporter::Server::TypeCollector
  include PrometheusExporter::Metric

  def type
    'move'
  end

  def metrics
    move_counter = PrometheusExporter::Metric::Counter.new('move_count', 'Number of moves in the system')
    move_counter.observe(Move.count)
    [move_counter]
  end
end
