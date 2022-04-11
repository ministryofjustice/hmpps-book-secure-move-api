# frozen_string_literal: true

require 'prometheus/client/data_stores/direct_file_store'

class Metrics
  include Singleton

  def initialize
    Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(
      dir: Rails.root.join("tmp/prometheus")
    )
  end
end
