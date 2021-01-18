# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByTimeBin do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('moves/counts_by_time_bin')
  end

  describe 'calculate' do
    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days exc today' } }

    before do
      create(:move, date: 4.days.ago)
      create(:move, date: Date.yesterday)
      create(:move, date: Date.today)
      create(:move, date: Date.tomorrow)
      create(:move, date: 4.days.from_now)
      create(:move, date: 8.days.from_now)
    end

    it 'computes the metric' do
      expect(metric.calculate('count', yesterday)).to be(1)
      expect(metric.calculate('count', next_7_days)).to be(2)
    end
  end
end
