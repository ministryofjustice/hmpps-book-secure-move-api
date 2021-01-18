# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByStatusTimeBin do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('moves/counts_by_status_time_bin')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(next_7_days) }

    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days exc today' } }

    before do
      create(:move, :completed, date: 4.days.ago)
      create(:move, :completed, date: Date.yesterday)
      create(:move, :cancelled, date: 7.days.from_now)
      create(:move, :in_transit, date: Date.today)
      create(:move, :requested, date: Date.tomorrow)
      create(:move, :requested, date: 4.days.from_now)
      create(:move, :requested, date: 8.days.from_now)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'cancelled' => 1,
          'requested' => 2,
          'total' => 3,
        },
      )
    end
  end
end
