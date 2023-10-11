# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::IdentifierTypesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => 'Bearer spoofed-token') }

  describe 'GET /api/v1/reference/identifier_types' do
    let(:schema) { load_yaml_schema('get_identifier_types_responses.yaml') }

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

    context 'when successful' do
      before do
        get '/api/v1/reference/identifier_types', headers:
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: expected_response)
      end
    end
  end
end
