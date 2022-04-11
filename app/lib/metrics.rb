# frozen_string_literal: true

require 'prometheus/client/data_stores/direct_file_store'

class Metrics
  include Singleton

  def initialize
    Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(
      dir: Rails.root.join('tmp/prometheus'),
    )

    registry = Prometheus::Client.registry

    @move_count_gauge = registry.gauge(
      :app_move_count_total,
      docstring: 'The total count of the number of moves.',
      store_settings: { aggregation: :max },
    )

    record_move_count
  end

  def record_move_count
    move_count_gauge.set(Move.unscoped.count)
  end

private

  attr_reader :move_count_gauge
end
