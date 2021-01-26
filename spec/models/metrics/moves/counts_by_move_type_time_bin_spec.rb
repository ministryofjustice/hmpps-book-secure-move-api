# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByMoveTypeTimeBin do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_type_time_bin')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(next_7_days) }

    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days exc today' } }

    before do
      create(:move, :prison_transfer, date: 4.days.ago)
      create(:move, :prison_transfer, date: Date.yesterday)
      create(:move, :prison_recall, date: Date.today)
      create(:move, :prison_recall, date: Date.tomorrow)
      create(:move, :hospital, date: Date.tomorrow)
      create(:move, :hospital, date: 4.days.from_now)
      create(:move, :hospital, date: 8.days.from_now)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'hospital' => 2,
          'prison_recall' => 1,
          'total' => 3,
        },
      )
    end
  end
end
