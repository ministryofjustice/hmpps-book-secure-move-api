# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByStatusMoveTimeBin do
  subject(:metric) { described_class.new }

  describe 'modules' do
    subject(:modules) { described_class.ancestors }

    it { is_expected.to include(Metrics::BaseMetric) }
    it { is_expected.to include(Metrics::PersonEscortRecords) }
    it { is_expected.to include(Metrics::TimeBins) }
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_status_move_time_bin')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(next_7_days) }

    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days exc today' } }

    before do
      create(:person_escort_record, move_attr: [:completed, date: 4.days.ago])
      create(:person_escort_record, :completed, move_attr: [:completed, date: Date.yesterday])
      create(:person_escort_record, :in_progress, move_attr: [:cancelled, date: 7.days.from_now])
      create(:person_escort_record, :in_progress, move_attr: [:in_transit, date: Date.today])
      create(:person_escort_record, move_attr: [:requested, date: Date.tomorrow])
      create(:person_escort_record, :completed, move_attr: [:requested, date: 4.days.from_now])
      create(:person_escort_record, :confirmed, move_attr: [:requested, date: 8.days.from_now])
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'unstarted' => 1,
          'in_progress' => 1,
          'completed' => 1,
          'total' => 3,
        },
      )
    end
  end
end
