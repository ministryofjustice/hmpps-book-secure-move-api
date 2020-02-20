# frozen_string_literal: true

RSpec.describe Api::V1::Reference::IdentifierTypesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/identifier_types' do
    let(:schema) { load_json_schema('get_identifier_types_responses.json') }

    let!(:identifier_types) do
      [
        create(:identifier_type),
        create(:identifier_type, :prison_number),
        create(:identifier_type, :criminal_records_office),
      ]
    end

    let(:expected_response) do
      identifier_types.map do |identifier_type|
        {
          type: 'identifier_types',
          id: identifier_type.id,
          attributes: {
            key: identifier_type.id,
            title: identifier_type.title,
            description: identifier_type.description,
          },
        }
      end
    end

    before do
      get '/api/v1/reference/identifier_types', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: expected_response)
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
end
