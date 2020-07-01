# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::SuppliersController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'GET /api/v1/reference/suppliers' do
    let(:schema) { load_yaml_schema('get_suppliers_responses.yaml') }

    let(:data) do
      [
        {
          type: 'suppliers',
          attributes: {
            name: 'Test Supplier 1',
            key: 'test_supplier_1',
          },
        },
        {
          type: 'suppliers',
          attributes: {
            name: 'Test Supplier 2',
            key: 'test_supplier_2',
          },
        },
      ]
    end

    before do
      data.each { |supplier| create(:supplier, supplier[:attributes]) }
    end

    context 'when successful' do
      before do
        get '/api/v1/reference/suppliers', headers: headers
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end
  end

  describe 'GET /api/v1/reference/suppliers/:id' do
    let(:schema) { load_yaml_schema('get_supplier_responses.yaml') }
    let(:params) { {} }
    let(:data) do
      {
        type: 'suppliers',
        attributes: {
          name: 'Test Supplier 1',
          key: 'test_supplier_1',
        },
      }
    end

    let!(:supplier) { create(:supplier, data[:attributes]) }
    let(:supplier_key) { supplier.key }

    context 'when successful' do
      before { get "/api/v1/reference/suppliers/#{supplier_key}", params: params, headers: headers }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when resource is not found' do
      let(:supplier_key) { 'UUID-not-found' }
      let(:detail_404) { "Couldn't find Supplier with UUID-not-found" }

      before { get "/api/v1/reference/suppliers/#{supplier_key}", params: params, headers: headers }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
