# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  it { is_expected.to have_and_belong_to_many(:suppliers) }
  it { is_expected.to have_many(:moves_from) }
  it { is_expected.to have_many(:moves_to) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:location_type) }

  context 'when location is a prison' do
    subject(:location) { build :location }

    it { expect(location.prison?).to be true }
    it { expect(location.police?).to be false }
    it { expect(location.court?).to be false }
  end

  context 'when location is a police custody unit' do
    subject(:location) { build :location, :police }

    it { expect(location.prison?).to be false }
    it { expect(location.police?).to be true }
    it { expect(location.court?).to be false }
  end

  context 'when location is a court' do
    subject(:location) { build :location, :court }

    it { expect(location.prison?).to be false }
    it { expect(location.police?).to be false }
    it { expect(location.court?).to be true }
  end

  describe '#supplier' do
    let(:supplier_one) { create(:supplier) }
    let(:supplier_two) { create(:supplier, name: 'Test Supplier 2') }
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
end
