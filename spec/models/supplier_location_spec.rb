# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupplierLocation do
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:location) }

  it 'prevents effective_from > effective_to' do
    expect(build(:supplier_location, effective_from: '2020-03-04', effective_to: '2020-03-03')).not_to be_valid
  end

  it 'allows effective_from == effective_to' do
    expect(build(:supplier_location, effective_from: '2020-03-04', effective_to: '2020-03-04')).to be_valid
  end

  describe '.link_locations' do
    let(:supplier) { create(:supplier) }
    let(:location1) { create(:location) }
    let(:location2) { create(:location) }

    it 'creates record for each location' do
      expect { described_class.link_locations(supplier:, locations: [location1, location2]) }.to change(described_class, :count).by(2)
    end

    it 'populates correct attributes' do
      described_class.link_locations(supplier:, locations: [location1])
      expect(described_class.last).to have_attributes(
        supplier:,
        location: location1,
        effective_from: nil,
        effective_to: nil,
      )
    end

    it 'populates explicit dates' do
      described_class.link_locations(supplier:, locations: [location1], effective_from: '2020-08-20', effective_to: '2020-12-31')
      expect(described_class.last).to have_attributes(
        supplier:,
        location: location1,
        effective_from: Date.parse('2020-08-20'),
        effective_to: Date.parse('2020-12-31'),
      )
    end
  end

  describe '.effective_on' do
    subject(:effective_on) { described_class.effective_on(date) }

    let(:location) { create(:location) }
    let(:supplier) { create(:supplier) }
    let(:date) { Time.zone.today }
    let(:supplier_location) { create(:supplier_location, supplier:, location:) }
    let(:supplier_other_locations) { [] }

    before do
      supplier_location
      supplier_other_locations
    end

    context 'with a nil date parameter' do
      let(:date) { nil }
      let(:supplier_other_locations) { create(:supplier_location, supplier:, location:, effective_from: Time.zone.today, effective_to: Time.zone.today) }

      it 'returns matching supplier locations, excluding matches that have an effective date' do
        expect(effective_on).to contain_exactly(supplier_location)
      end
    end

    context 'without an effective from or to date' do
      it 'returns matching supplier locations, ignoring effective dates completely' do
        expect(effective_on).to contain_exactly(supplier_location)
      end
    end

    context 'with only an effective from date' do
      let(:supplier_location) { create(:supplier_location, supplier:, location:, effective_from: date) }
      let(:supplier_other_locations) { create(:supplier_location, supplier:, location:, effective_from: date.tomorrow) }

      it 'returns matching supplier locations, excluding ineffective future matches' do
        expect(effective_on).to contain_exactly(supplier_location)
      end
    end

    context 'with only an effective to date' do
      let(:supplier_location) { create(:supplier_location, supplier:, location:, effective_to: date) }
      let(:supplier_other_locations) { create(:supplier_location, supplier:, location:, effective_to: date.yesterday) }

      it 'returns matching supplier locations, excluding ineffective expired matches' do
        expect(effective_on).to contain_exactly(supplier_location)
      end
    end

    context 'with effective from and to date' do
      let(:supplier_location) { create(:supplier_location, supplier:, location:, effective_from: date, effective_to: date) }
      let(:supplier_other_locations) do
        [
          create(:supplier_location, supplier:, location:, effective_to: date.yesterday),
          create(:supplier_location, supplier:, location:, effective_from: date.tomorrow),
        ]
      end

      it 'returns matching supplier locations, excluding ineffective future and expired matches' do
        expect(effective_on).to contain_exactly(supplier_location)
      end
    end
  end
end
