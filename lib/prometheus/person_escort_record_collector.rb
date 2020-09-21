# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class PersonEscortRecordCollector < PrometheusExporter::Server::TypeCollector
  include PrometheusExporter::Metric

  def type
    'person_escort_record'
  end

  def metrics
    metric = PrometheusExporter::Metric::Gauge.new('person_escort_record_gauge', 'Number of PERs in the system')
    statuses = [nil] + PersonEscortRecord.statuses.keys

    statuses.each do |status|
      observe_metric(metric, status: status) # all time

      # only confirmed PERs will have a confirmed_at timestamp
      next unless status == PersonEscortRecord::PERSON_ESCORT_RECORD_CONFIRMED

      observe_metric(metric, status: status, confirmed_at_from_offset: nil, confirmed_at_to_offset: 0) # the past
      observe_metric(metric, status: status, confirmed_at_from_offset: -29, confirmed_at_to_offset: 0) # the past 30 days
      observe_metric(metric, status: status, confirmed_at_from_offset: -6, confirmed_at_to_offset: 0) # the past week
      observe_metric(metric, status: status, confirmed_at_from_offset: -1, confirmed_at_to_offset: -1) # yesterday
      observe_metric(metric, status: status, confirmed_at_from_offset: 0, confirmed_at_to_offset: 0) # today
    end

    [metric]
  end

private

  def observe_metric(metric, status: nil, confirmed_at_from_offset: nil, confirmed_at_to_offset: nil)
    # TODO: investigate how to move these queries to a read-only replica database
    pers = PersonEscortRecord
    pers = pers.where(status: status) if status.present?
    pers = pers.where('confirmed_at >= ?', Time.zone.today.midnight + confirmed_at_from_offset.days) if confirmed_at_from_offset.present?
    pers = pers.where('confirmed_at < ?', Time.zone.tomorrow.midnight + confirmed_at_to_offset.days) if confirmed_at_to_offset.present?

    metric.observe(pers.count, status: status, confirmed_at_from_offset: confirmed_at_from_offset, confirmed_at_to_offset: confirmed_at_to_offset)
  end
end
