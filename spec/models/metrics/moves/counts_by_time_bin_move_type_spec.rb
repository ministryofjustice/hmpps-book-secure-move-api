# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByTimeBinMoveType do
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
      create(:move, :prison_transfer, date: 4.days.ago)
      create(:move, :prison_transfer, date: Date.yesterday)
      create(:move, :prison_recall, date: Date.yesterday)
      create(:move, :prison_recall, date: Date.today)
      create(:move, :hospital, date: Date.tomorrow)
      create(:move, :hospital, date: 4.days.from_now)
      create(:move, :hospital, date: 8.days.from_now)
    end

    it 'computes the metric' do
      expect(metric.calculate(yesterday, :prison_transfer)).to be(1)
      expect(metric.calculate(next_7_days, :hospital)).to be(2)
    end
  end
end
