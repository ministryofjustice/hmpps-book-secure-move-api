# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByMoveTimeBin do
  subject(:metric) { described_class.new }

  describe 'modules' do
    subject(:modules) { described_class.ancestors }

    it { is_expected.to include(Metrics::BaseMetric) }
    it { is_expected.to include(Metrics::PersonEscortRecords) }
    it { is_expected.to include(Metrics::TimeBins) }
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_time_bin')
  end

  describe 'calculate' do
    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days exc today' } }

    before do
      create(:person_escort_record, move_attr: [date: 4.days.ago])
      create(:person_escort_record, move_attr: [date: Date.yesterday])
      create(:person_escort_record, move_attr: [date: Time.zone.today])
      create(:person_escort_record, move_attr: [date: Date.tomorrow])
      create(:person_escort_record, move_attr: [date: 4.days.from_now])
      create(:person_escort_record, move_attr: [date: 8.days.from_now])
    end

    it 'computes the metric' do
      expect(metric.calculate('count', yesterday)).to be(1)
      expect(metric.calculate('count', next_7_days)).to be(2)
    end
  end
end
