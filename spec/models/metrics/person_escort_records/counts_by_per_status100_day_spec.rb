# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByPerStatus100Day do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and PersonEscortRecords modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_per_status_100_day')
  end

  describe 'calculate_table' do
    subject(:calculate_table) { metric.calculate_table }

    before do
      create(:person_escort_record, :unstarted, move_attr: [:completed, { date: Date.tomorrow }])
      create(:person_escort_record, :unstarted, move_attr: [:completed, { date: Date.yesterday }])
      create(:person_escort_record, :in_progress, move_attr: [:completed, { date: Time.zone.today }])
      create(:person_escort_record, :in_progress, move_attr: [:cancelled, { date: Date.yesterday }])
      create(:person_escort_record, :completed, move_attr: [:cancelled, { date: 10.days.ago }])
      create(:person_escort_record, :confirmed, move_attr: [:in_transit, { date: 10.days.ago }])
      create(:person_escort_record, :confirmed, move_attr: [:requested, { date: 1.year.ago }])
    end

    context 'with relevant dates' do
      let(:yesterday) { Time.zone.yesterday.iso8601 }
      let(:ten_days_ago) { (Time.zone.today - 10.days).iso8601 }

      it { expect(calculate_table["unstarted__#{yesterday}"]).to be(1) }
      it { expect(calculate_table["in_progress__#{yesterday}"]).to be(1) }
      it { expect(calculate_table["completed__#{yesterday}"]).to be(0) }
      it { expect(calculate_table["confirmed__#{yesterday}"]).to be(0) }
      it { expect(calculate_table["total__#{yesterday}"]).to be(2) }

      it { expect(calculate_table["unstarted__#{ten_days_ago}"]).to be(0) }
      it { expect(calculate_table["in_progress__#{ten_days_ago}"]).to be(0) }
      it { expect(calculate_table["completed__#{ten_days_ago}"]).to be(1) }
      it { expect(calculate_table["confirmed__#{ten_days_ago}"]).to be(1) }
      it { expect(calculate_table["total__#{ten_days_ago}"]).to be(2) }
    end

    context 'with excluded dates' do
      let(:tomorrow) { Time.zone.tomorrow.iso8601 }
      let(:today) { Time.zone.today.iso8601 }
      let(:one_year_ago) { (Time.zone.today - 1.year).iso8601 }

      it 'excludes tomorrow' do
        expect(calculate_table["completed__#{tomorrow}"]).to be(0)
      end

      it 'excludes today' do
        expect(calculate_table["completed__#{today}"]).to be(0)
      end

      it 'excludes last year' do
        expect(calculate_table["requested__#{one_year_ago}"]).to be(0)
      end
    end
  end
end
