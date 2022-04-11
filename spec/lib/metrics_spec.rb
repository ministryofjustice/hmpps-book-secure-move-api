# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics do
  subject(:instance) { described_class.send(:new) }

  let(:config) { instance_double(Prometheus::Client::Config) }
  let(:registry) { instance_double(Prometheus::Client::Registry) }
  let(:move_count_gauge) { instance_double(Prometheus::Client::Gauge) }

  before do
    allow(config).to receive(:data_store=)
    allow(Prometheus::Client).to receive(:config).and_return(config)

    allow(move_count_gauge).to receive(:set)
    allow(registry).to receive(:gauge).with(:app_move_count_total, anything).and_return(move_count_gauge)
    allow(Prometheus::Client).to receive(:registry).and_return(registry)
  end

  it 'sets the data store' do
    expect(config).to receive(:data_store=).with(instance_of(Prometheus::Client::DataStores::DirectFileStore))
    instance
  end

  it 'sets the move count' do
    expect(move_count_gauge).to receive(:set)
    instance
  end

  describe '#record_move_count' do
    it 'sets the move count' do
      expect(move_count_gauge).to receive(:set)
      instance.record_move_count
    end
  end
end
