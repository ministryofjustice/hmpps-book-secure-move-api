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
      expect { described_class.link_locations(supplier: supplier, locations: [location1, location2]) }.to change(described_class, :count).by(2)
    end

    it 'populates correct attributes' do
      described_class.link_locations(supplier: supplier, locations: [location1])
      expect(described_class.last).to have_attributes(
        supplier: supplier,
        location: location1,
        effective_from: nil,
        effective_to: nil,
      )
    end

    it 'populates explicit dates' do
      described_class.link_locations(supplier: supplier, locations: [location1], effective_from: '2020-08-20', effective_to: '2020-12-31')
      expect(described_class.last).to have_attributes(
        supplier: supplier,
        location: location1,
        effective_from: Date.parse('2020-08-20'),
        effective_to: Date.parse('2020-12-31'),
      )
    end
  end
end
