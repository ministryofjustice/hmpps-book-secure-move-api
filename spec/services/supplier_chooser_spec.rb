RSpec.describe SupplierChooser do
  subject(:service) { described_class.new(move_or_allocation) }

  let!(:serco) { create(:supplier, key: 'serco') }
  let(:supplier1) { create(:supplier) }
  let(:supplier2) { create(:supplier) }
  let(:location) { create(:location) }
  let(:date) { Date.today }
  let(:move_or_allocation) { build(:move, from_location: location, date: date) }

  context 'with a move with a date' do
    let(:move_or_allocation) { build(:move, from_location: location, date: date, date_from: nil) }
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date) }

    it 'returns matching supplier, effective on move date' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with a move without a date' do
    let(:move_or_allocation) { build(:move, from_location: location, date: nil, date_from: date) }
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date) }

    it 'returns matching supplier, effective on move from_date' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an allocation with a date' do
    let(:move_or_allocation) { build(:allocation, from_location: location, date: date) }
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date) }

    it 'returns matching supplier, effective on allocation date' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an allocation without a date' do
    let(:move_or_allocation) { build(:allocation, from_location: location, date: nil) }
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date) }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'without an effective from or to date' do
    let!(:supplier_location) { create(:supplier_location, supplier: supplier1, location: location) }

    it 'returns matching supplier, ignoring effective dates completely' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with only an effective from date' do
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date) }
    let!(:supplier_location2) { create(:supplier_location, supplier: supplier2, location: location, effective_from: date.tomorrow) }

    it 'returns matching supplier, excluding ineffective future matches' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with only an effective to date' do
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_to: date) }
    let!(:supplier_location2) { create(:supplier_location, supplier: supplier2, location: location, effective_to: date.yesterday) }

    it 'returns matching supplier, excluding ineffective expired matches' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an effective from and to date' do
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date, effective_to: date) }
    let!(:supplier_location2) { create(:supplier_location, supplier: supplier2, location: location, effective_to: date.yesterday) }
    let!(:supplier_location3) { create(:supplier_location, supplier: supplier2, location: location, effective_from: date.tomorrow) }

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
    let!(:supplier_location) { create(:supplier_location, supplier: supplier1) }

    it 'returns nil' do
      expect(service.call).to be_nil
    end
  end

  context 'with no matching effective date' do
    let!(:supplier_location) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date.tomorrow, effective_to: date.tomorrow) }

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
