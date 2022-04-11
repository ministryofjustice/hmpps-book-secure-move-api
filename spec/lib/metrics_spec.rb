# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics do
  subject(:instance) { Metrics.instance }

  it 'sets the data store' do
    expect(Prometheus::Client.config.data_store).to be_instance_of(Prometheus::Client::DataStores::DirectFileStore)
  end
end
