# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::SuppliersController do
  subject(:get_supplier_locations) { get "/api/v1/suppliers/#{supplier_id}/locations#{query_params}", headers:, params: {} }

  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'Authorization': "Bearer #{access_token}" } }
  let(:response_json) { JSON.parse(response.body) }
  let(:query_params) { '' }

  describe 'GET /suppliers/:supplier_id/locations' do
    let(:schema) { load_yaml_schema('get_locations_responses.yaml') }

    let(:supplier) { create(:supplier) }
    let(:supplier_id) { supplier.id }
    let(:location_a) { create(:location, suppliers: [supplier], key: 'key_aaa') }
    let(:location_b) { create(:location, suppliers: [supplier], key: 'key_bbb') }

    it_behaves_like 'an endpoint that responds with success 200' do
      before do
        create(:move, :requested, supplier:)

        get_supplier_locations
      end
    end

    it 'returns the locations' do
      create_list(:move, 2, :requested, supplier:, from_location: location_a) # to tests that duplicates locations are not shown
      create(:move, :requested, supplier:, from_location: location_b)

      get_supplier_locations

      response_location_keys = response_json['data']
                                 .select { |e| e['type'] == 'locations' }
                                 .map { |l| l['attributes']['key'] }

      expect(response_location_keys).to eq(%w[key_aaa key_bbb])
    end

    context 'when other locations are present' do
      it 'does not include those into the response' do
        another_supplier = create(:supplier)
        another_location = create(:location, suppliers: [another_supplier])
        create(:move, :requested, supplier: another_supplier, from_location: another_location)
        create(:move, :requested, supplier:, from_location: location_a)

        get_supplier_locations

        response_location_keys = response_json['data']
                                     .select { |e| e['type'] == 'locations' }
                                     .map { |l| l['attributes']['key'] }

        expect(response_location_keys).to eq(%w[key_aaa])
      end
    end
  end

  context 'when the supplier_id is not found' do
    let(:schema) { load_yaml_schema('error_responses.yaml') }

    let(:supplier_id) { 'invalid-supplier-id' }
    let(:detail_404) { "Couldn't find Supplier with 'id'=invalid-supplier-id" }

    before do
      get_supplier_locations
    end

    it_behaves_like 'an endpoint that responds with error 404'
  end

  context 'when including the include query param' do
    let(:query_params) { '?include=suppliers' }
    let(:supplier) { create(:supplier) }
    let(:supplier_id) { supplier.id }

    it 'returns the valid provided includes' do
      location = create(:location, suppliers: [supplier])
      create(:move, :requested, supplier:, from_location: location)

      get_supplier_locations

      returned_types = response_json['included'].map { |r| r['type'] }.uniq
      expect(returned_types).to contain_exactly('suppliers')
    end
  end
end
