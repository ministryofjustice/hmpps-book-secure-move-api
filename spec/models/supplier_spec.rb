# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Supplier, type: :model do
  subject(:supplier) { create(:supplier, name: 'Test Supplier 123') }

  it { is_expected.to have_many(:supplier_locations) }
  it { is_expected.to have_many(:locations).through(:supplier_locations) }
  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to have_many(:moves) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_uniqueness_of(:key) }

  context 'when not providing a key' do
    it 'generates it from the name' do
      expect(supplier.key).to eq('test_supplier_123')
    end
  end

  describe '#for_feed' do
    let(:expected_json) do
      {
        'supplier' => supplier.key,
      }
    end

    it 'generates a feed document' do
      expect(supplier.for_feed).to include_json(expected_json)
    end
  end
end
