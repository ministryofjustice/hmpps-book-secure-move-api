RSpec.describe SupplierChooser do
  subject(:service) do
    described_class.new(
      effective_date: date,
      location: location,
      new_record: new_record,
      doorkeeper_application_owner: doorkeeper_application_owner,
      existing_owner: existing_owner,
    )
  end

  let(:supplier1) { create(:supplier) }
  let(:supplier2) { create(:supplier) }
  let(:supplier3) { create(:supplier) }
  let(:location) { create(:location) }
  let(:date) { Date.today }
  let(:doorkeeper_application_owner) { nil }
  let(:existing_owner) { nil }

  context 'when new record' do
    let(:new_record) { true }

    context 'with doorkeeper_application_owner' do
      let(:doorkeeper_application_owner) { supplier2 }
      let!(:supplier_location) { create(:supplier_location, supplier: supplier1, location: location) }

      it 'ignores the matching supplier location and returns the doorkeeper app owner' do
        expect(service.call).to eq(doorkeeper_application_owner)
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

  context 'when an existing record' do
    let(:new_record) { false }

    context 'with doorkeeper_application_owner' do
      let(:doorkeeper_application_owner) { supplier2 }
      let!(:supplier_location) { create(:supplier_location, supplier: supplier1, location: location) }

      it 'ignores doorkeeper app owner and returns the matching supplier location' do
        expect(service.call).to eq(supplier1)
      end
    end

    context 'with existing owner' do
      let(:existing_owner) { supplier2 }
      let!(:supplier_location) { create(:supplier_location, supplier: supplier1, location: location) }

      it 'ignores existing_owner and returns the matching supplier location' do
        expect(service.call).to eq(supplier1)
      end
    end

    context 'without supplier_location owner' do
      let(:existing_owner) { supplier2 }
      let(:doorkeeper_application_owner) { supplier3 }

      it 'returns the existing_owner and ignores the doorkeeper app owner' do
        expect(service.call).to eq(supplier2)
      end
    end

    context 'without supplier_location or existing owner' do
      let(:doorkeeper_application_owner) { supplier3 }

      it 'returns the doorkeeper app owner' do
        expect(service.call).to eq(supplier3)
      end
    end

    context 'without supplier_location or existing owner or doorkeeper app owner' do
      it 'returns nil' do
        expect(service.call).to be nil
      end
    end
  end
end
