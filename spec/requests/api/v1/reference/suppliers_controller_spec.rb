# frozen_string_literal: true

RSpec.describe Api::V1::Reference::SuppliersController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/suppliers' do
    let(:schema) { load_json_schema('get_suppliers_responses.json') }

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
      data.each { |supplier| Supplier.create!(supplier[:attributes]) }

      get '/api/v1/reference/suppliers', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end

  describe 'GET /api/v1/reference/suppliers/:id' do
    let(:schema) { load_json_schema('get_supplier_responses.json') }
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

    let!(:supplier) { Supplier.create!(data[:attributes]) }
    let(:supplier_key) { supplier.key }

    context 'when successful' do
      before { get "/api/v1/reference/suppliers/#{supplier_key}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      before { get "/api/v1/reference/suppliers/#{supplier_key}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { get "/api/v1/reference/suppliers/#{supplier_key}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'when resource is not found' do
      let(:supplier_key) { 'UUID-not-found' }
      let(:detail_404) { "Couldn't find Supplier with UUID-not-found" }

      before { get "/api/v1/reference/suppliers/#{supplier_key}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
