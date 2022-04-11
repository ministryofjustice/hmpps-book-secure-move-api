# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics do
  subject(:instance) { described_class.send(:new) }

  let(:registry) { instance_double(Prometheus::Client::Registry) }

  before do
    allow(Prometheus::Client).to receive(:registry).and_return(registry)
  end

  describe '#configure' do
    let(:config) { instance_double(Prometheus::Client::Config) }

    before do
      allow(config).to receive(:data_store=)
      allow(Prometheus::Client).to receive(:config).and_return(config)
    end

    after { instance.configure }

    it 'sets the data store' do
      expect(config).to receive(:data_store=).with(instance_of(Prometheus::Client::DataStores::DirectFileStore))
    end
  end

  describe '#record_move_count' do
    let(:move_count_gauge) { instance_double(Prometheus::Client::Gauge) }

    before do
      allow(move_count_gauge).to receive(:set)
      allow(registry).to receive(:gauge).with(:app_move_count_total, anything).and_return(move_count_gauge)

      create(:move, :booked)
      create(:move, :requested)
    end

    after { instance.record_move_count }

    it 'sets the move count based on the status' do
      expect(move_count_gauge).to receive(:set).with(1, labels: { status: 'booked' })
      expect(move_count_gauge).to receive(:set).with(1, labels: { status: 'requested' })
    end
  end
end
