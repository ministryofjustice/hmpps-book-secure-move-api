RSpec.describe SupplierChooser do
  subject(:service) { described_class.new(date, location) }

  let(:supplier1) { create(:supplier) }
  let(:supplier2) { create(:supplier) }
  let(:location) { create(:location) }
  let(:date) { Date.today }

  context 'without an effective from or to date' do
    let!(:supplier_location) { create(:supplier_location, supplier: supplier1, location: location) }

    it 'returns matching supplier' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with only an effective from date' do
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date) }
    let!(:supplier_location2) { create(:supplier_location, supplier: supplier2, location: location, effective_from: date.tomorrow) }

    it 'returns matching supplier' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with only an effective to date' do
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_to: date) }
    let!(:supplier_location2) { create(:supplier_location, supplier: supplier2, location: location, effective_to: date.yesterday) }

    it 'returns matching supplier' do
      expect(service.call).to eq(supplier1)
    end
  end

  context 'with an effective from and to date' do
    let!(:supplier_location1) { create(:supplier_location, supplier: supplier1, location: location, effective_from: date, effective_to: date) }
    let!(:supplier_location2) { create(:supplier_location, supplier: supplier2, location: location, effective_to: date.yesterday) }
    let!(:supplier_location3) { create(:supplier_location, supplier: supplier2, location: location, effective_from: date.tomorrow) }

    it 'returns matching supplier' do
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
