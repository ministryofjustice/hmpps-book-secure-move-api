# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::SuppliersController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /suppliers/:supplier_id/locations' do
    let(:supplier) { create(:supplier) }

    it 'returns the locations' do
      location1 = create(:location, suppliers: [supplier])
      location2 = create(:location, suppliers: [supplier])
      create_list(:move, 2, :requested, supplier: supplier, from_location: location1) # to tests that duplicates locations are not shown
      create(:move, :requested, supplier: supplier, from_location: location2)

      get "/api/v1/suppliers/#{supplier.id}/locations", headers: headers, params: {}

      response_location_keys = response_json['data']
                                 .select { |e| e['type'] == 'locations' }
                                 .map { |l| l['attributes']['key'] }

      expect(response).to have_http_status(:success)
      expect(response_location_keys).to match_array([location1.key, location2.key])
    end
  end

  context 'when the supplier_id is not found' do
    let(:schema) { load_yaml_schema('error_responses.yaml') }

    let(:supplier_id) { 'invalid-supplier-id' }
    let(:detail_404) { "Couldn't find Supplier with 'id'=invalid-supplier-id" }

    before do
      get "/api/v1/suppliers/#{supplier_id}/locations", headers: headers, params: {}
    end

    it_behaves_like 'an endpoint that responds with error 404'
  end
end
