# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class MoveCollector < PrometheusExporter::Server::TypeCollector
  include PrometheusExporter::Metric

  def type
    'move'
  end

  def metrics
    metric = PrometheusExporter::Metric::Gauge.new('move_gauge', 'Number of moves in the system')
    metric.observe(0) # temporarily disabled

    [metric]
  end
end
