# frozen_string_literal: true

RSpec.describe Supplier, type: :model do
  subject(:supplier) { create(:supplier) }

  it { is_expected.to have_and_belong_to_many(:locations) }
  it { is_expected.to have_many(:subscriptions) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_uniqueness_of(:key) }

  context 'when not providing a key' do
    it 'generates it from the name' do
      expect(supplier.key).to eq('test_supplier_1')
    end
  end
end
