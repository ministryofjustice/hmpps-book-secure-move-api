# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByTimeBinStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label' do
    expect(metric.label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate' do
    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days' } }

    before do
      create(:move, :completed, date: 4.days.ago)
      create(:move, :completed, date: Date.yesterday)
      create(:move, :cancelled, date: Date.yesterday)
      create(:move, :in_transit, date: Date.today)
      create(:move, :requested, date: Date.tomorrow)
      create(:move, :requested, date: 4.days.from_now)
      create(:move, :requested, date: 8.days.from_now)
    end

    it 'computes the metric' do
      expect(metric.calculate(yesterday, 'completed')).to be(1)
      expect(metric.calculate(next_7_days, 'requested')).to be(2)
    end
  end
end
