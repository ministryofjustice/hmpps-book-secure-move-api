# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  it { is_expected.to have_and_belong_to_many(:suppliers) }
  it { is_expected.to have_many(:moves_from) }
  it { is_expected.to have_many(:moves_to) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:location_type) }
  it { is_expected.to define_enum_for(:location_type).backed_by_column_of_type(:string) }

  context 'when location is a court' do
    subject(:location) { build :location, :court }

    it { expect(location.detained?).to be false }
    it { expect(location.not_detained?).to be true }
  end

  context 'when location is a police custody unit' do
    subject(:location) { build :location, :police }

    it { expect(location.detained?).to be false }
    it { expect(location.not_detained?).to be true }
  end

  context 'when location is a prison' do
    subject(:location) { build :location }

    it { expect(location.detained?).to be true }
    it { expect(location.not_detained?).to be false }
  end

  context 'when location is a secure childrens hospital' do
    subject(:location) { build :location, :sch }

    it { expect(location.detained?).to be true }
    it { expect(location.not_detained?).to be false }
  end

  context 'when location is a secure training centre' do
    subject(:location) { build :location, :stc }

    it { expect(location.detained?).to be true }
    it { expect(location.not_detained?).to be false }
  end

  describe '#supplier' do
    let(:supplier_one) { create(:supplier) }
    let(:supplier_two) { create(:supplier) }
    let!(:location_one) { create(:location, suppliers: [supplier_one]) }
    let!(:location_two) { create(:location, suppliers: [supplier_two]) }

    context 'when querying with first supplier' do
      it 'finds the right location' do
        expect(described_class.supplier(supplier_one.id)).to include(location_one)
      end

      it 'finds the right number of locations' do
        expect(described_class.supplier(supplier_one.id).count).to eq(1)
      end
    end

    context 'when querying with second supplier' do
      it 'finds the right location' do
        expect(described_class.supplier(supplier_two.id)).to include(location_two)
      end

      it 'finds the right number of locations' do
        expect(described_class.supplier(supplier_two.id).count).to eq(1)
      end
    end
  end

  describe '#for_feed' do
    subject(:location) { create(:location) }

    context 'when a prefix is supplied' do
      let(:prefix) { 'from' }
      let(:expected_json) do
        {
          'from_location_type' => location.location_type,
          'from_location' => location.nomis_agency_id,
        }
      end

      it 'generates a feed document' do
        expect(location.for_feed(prefix: prefix)).to include_json(expected_json)
      end
    end

    context 'when a prefix is not supplied' do
      let(:expected_json) do
        {
          'location_type' => location.location_type,
          'location' => location.nomis_agency_id,
        }
      end

      it 'generates a feed document' do
        expect(location.for_feed).to include_json(expected_json)
      end
    end
  end
end
