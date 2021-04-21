# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByTimeBin do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric, PersonEscortRecords and TimeBins modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
    expect(described_class.ancestors).to include(Metrics::TimeBins)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_time_bin')
  end

  describe 'calculate' do
    let(:yesterday) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'yesterday' } }
    let(:next_7_days) { Metrics::TimeBins::COMMON_TIME_BINS.find { |x| x.title == 'next 7 days exc today' } }

    before do
      create(:person_escort_record, date: 4.days.ago)
      create(:person_escort_record, date: Date.yesterday)
      create(:person_escort_record, date: Date.today)
      create(:person_escort_record, date: Date.tomorrow)
      create(:person_escort_record, date: 4.days.from_now)
      create(:person_escort_record, date: 8.days.from_now)
    end

    it 'computes the metric' do
      expect(metric.calculate('count', yesterday)).to be(1)
      expect(metric.calculate('count', next_7_days)).to be(2)
    end
  end
end
