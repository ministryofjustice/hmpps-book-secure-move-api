# frozen_string_literal: true

require 'prometheus/client/data_stores/direct_file_store'

Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(dir: Rails.root.join("tmp/prometheus"))
