RSpec.describe SupplierChooser do
  subject(:service) { described_class.new(doorkeeper_application_owner, from_location) }

  let(:from_location) { instance_double('Location', suppliers: [supplier_one, supplier_two]) }
  let(:supplier_one) { instance_double('Supplier') }
  let(:supplier_two) { instance_double('Supplier') }

  context 'when doorkeeper_application_owner is nil' do
    let(:doorkeeper_application_owner) { nil }

    it 'returns the first supplier from move.from_location.suppliers' do
      expect(service.call).to eq(supplier_one)
    end
  end

  context 'when doorkeeper_application_owner is present' do
    let(:doorkeeper_application_owner) { instance_double('Supplier') }

    it 'returns the doorkeeper_application_owner' do
      expect(service.call).to eq(doorkeeper_application_owner)
    end
  end
end
