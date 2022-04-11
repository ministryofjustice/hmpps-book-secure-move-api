# frozen_string_literal: true

require 'prometheus/client/data_stores/direct_file_store'

class Metrics
  include Singleton

  def configure
    Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(
      dir: Rails.root.join('tmp/prometheus'),
    )
  end

  def record_move_count
    Move.unscoped.group(:status).count.each do |status, count|
      move_count_gauge.set(count, labels: { status: status })
    end
  end

private

  def registry
    @registry ||= Prometheus::Client.registry
  end

  def move_count_gauge
    @move_count_gauge ||= registry.gauge(
      :app_move_count_total,
      docstring: 'The total count of the number of moves.',
      labels: %i[status],
      store_settings: { aggregation: :max },
    )
  end
end
