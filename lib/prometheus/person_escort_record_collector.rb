# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class PersonEscortRecordCollector < PrometheusExporter::Server::TypeCollector
  include PrometheusExporter::Metric

  def type
    'person_escort_record'
  end

  def metrics
    metric = PrometheusExporter::Metric::Gauge.new('person_escort_record_gauge', 'Number of PERs in the system')
    metric.observe(0) # temporarily disabled

    [metric]
  end
end
