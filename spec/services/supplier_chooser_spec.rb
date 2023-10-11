require 'rails_helper'

RSpec.describe SupplierChooser do
  subject(:service) { described_class.new(move_or_allocation) }

  let(:supplier1) { create(:supplier) }
  let(:supplier2) { create(:supplier) }
  let(:location) { create(:location) }
  let(:date) { Time.zone.today }
  let(:move_or_allocation) { build(:move, from_location: location, date:) }

  context 'with a move with a date' do
    let(:move_or_allocation) { build(:move, from_location: location, date:, date_from: nil) }

    before { create(:supplier_location, supplier: supplier1, location:, effective_from: date) }

    it 'returns matching supplier, effective on move date' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with a move without a date' do
    let(:move_or_allocation) { build(:move, from_location: location, date: nil, date_from: date) }

    before { create(:supplier_location, supplier: supplier1, location:, effective_from: date) }

    it 'returns matching supplier, effective on move from_date' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an allocation with a date' do
    let(:move_or_allocation) { build(:move, from_location: location, date:) }

    before { create(:supplier_location, supplier: supplier1, location:, effective_from: date) }

    it 'returns matching supplier, effective on allocation date' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an allocation without a date' do
    let(:move_or_allocation) { build(:allocation, from_location: location, date: nil) }

    before { create(:supplier_location, supplier: supplier1, location:, effective_from: date) }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'without an effective from or to date' do
    before { create(:supplier_location, supplier: supplier1, location:) }

    it 'returns matching supplier, ignoring effective dates completely' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with only an effective from date' do
    before do
      create(:supplier_location, supplier: supplier1, location:, effective_from: date)
      create(:supplier_location, supplier: supplier2, location:, effective_from: date.tomorrow)
    end

    it 'returns matching supplier, excluding ineffective future matches' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with only an effective to date' do
    before do
      create(:supplier_location, supplier: supplier1, location:, effective_to: date)
      create(:supplier_location, supplier: supplier2, location:, effective_to: date.yesterday)
    end

    it 'returns matching supplier, excluding ineffective expired matches' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an effective from and to date' do
    before do
      create(:supplier_location, supplier: supplier1, location:, effective_from: date, effective_to: date)
      create(:supplier_location, supplier: supplier2, location:, effective_to: date.yesterday)
      create(:supplier_location, supplier: supplier2, location:, effective_from: date.tomorrow)
    end

    it 'returns matching supplier, excluding ineffective future and expired matches' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with no supplier locations' do
    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'with no matching location' do
    before { create(:supplier_location, supplier: supplier1) }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'with no matching effective date' do
    before { create(:supplier_location, supplier: supplier1, location:, effective_from: date.tomorrow, effective_to: date.tomorrow) }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'with nil date parameter' do
    let(:date) { nil }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'with nil location parameter' do
    let(:location) { nil }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end
end
