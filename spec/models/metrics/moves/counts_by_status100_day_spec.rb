# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByStatus100Day do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_status_100_day')
  end

  describe 'calculate_table' do
    subject(:calculate_table) { metric.calculate_table }

    before do
      create(:move, :completed, date: Date.tomorrow)
      create(:move, :completed, date: Time.zone.today)
      create(:move, :cancelled, date: Date.yesterday)
      create(:move, :cancelled, date: 10.days.ago)
      create(:move, :in_transit, date: 10.days.ago)
      create(:move, :requested, date: 1.year.ago)
    end

    context 'with relevant dates' do
      let(:yesterday) { Time.zone.yesterday.iso8601 }
      let(:ten_days_ago) { (Time.zone.today - 10.days).iso8601 }

      it { expect(calculate_table["completed__#{yesterday}"]).to be(0) }
      it { expect(calculate_table["cancelled__#{yesterday}"]).to be(1) }
      it { expect(calculate_table["total__#{yesterday}"]).to be(1) }

      it { expect(calculate_table["requested__#{ten_days_ago}"]).to be(0) }
      it { expect(calculate_table["completed__#{ten_days_ago}"]).to be(0) }
      it { expect(calculate_table["cancelled__#{ten_days_ago}"]).to be(1) }
      it { expect(calculate_table["in_transit__#{ten_days_ago}"]).to be(1) }
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
