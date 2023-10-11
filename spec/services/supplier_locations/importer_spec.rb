# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupplierLocations::Importer do
  subject(:call_importer) { importer.call }

  let(:importer) { described_class.new(filename) }
  let(:filename) { file_fixture('supplier_locations/valid.yaml') }

  context 'with valid file' do
    let(:effective_from) { Date.parse('2020-08-20') }
    let(:effective_to) { Date.parse('2020-12-31') }

    let!(:supplier1) { create(:supplier, key: 'supplier1') }
    let!(:location1) { create(:location, nomis_agency_id: 'LOC1') }

    before do
      create(:supplier, key: 'supplier2')
      create(:location, nomis_agency_id: 'LOC2')
      create(:location, nomis_agency_id: 'LOC3')
    end

    it 'creates expected supplier locations' do
      # valid.yaml contains two suppliers each mapped to two known locations (plus an unknown location)
      expect { call_importer }.to change(SupplierLocation, :count).by(4)
    end

    it 'sets the correct attributes on each supplier location' do
      call_importer
      supplier_location = SupplierLocation.find_by(supplier: supplier1, location: location1)
      expect(supplier_location).to have_attributes(
        effective_from:,
        effective_to:,
      )
    end
  end

  context 'with invalid filename' do
    let(:filename) { 'not_found.yaml' }

    it 'throws an error' do
      expect { call_importer }.to raise_error(Errno::ENOENT)
    end
  end

  context 'with invalid dates in file' do
    let(:filename) { file_fixture('supplier_locations/invalid_dates.yaml') }

    it 'throws an error' do
      expect { call_importer }.to raise_error(ArgumentError)
    end
  end

  context 'with missing dates in file' do
    let(:filename) { file_fixture('supplier_locations/missing_dates.yaml') }

    it 'throws an error' do
      expect { call_importer }.to raise_error(RuntimeError, /Invalid\ dates/)
    end
  end

  context 'with no suppliers in file' do
    let(:filename) { file_fixture('supplier_locations/no_suppliers.yaml') }

    it 'throws an error' do
      expect { call_importer }.to raise_error(RuntimeError, 'No suppliers found in file')
    end
  end
end
