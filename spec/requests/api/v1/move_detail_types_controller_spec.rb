# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::MoveDetailTypesController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'GET /api/v1/reference/move_detail_types' do
    let(:expected_data) do
      [
        {
          id: '3852df1a-3301-4d69-f200-69e482ce1ed8',
          type: 'move_detail_types',
          attributes: {
            move_detail_category: 'health',
            user_type: 'prison',
            alert_type: 'M',
            alert_code: 'MSI',
            type_description: 'Medical',
            description: 'Sight Impaired'
          }
        }
      ]
    end

    context 'with the correct CONTENT_TYPE header' do
      it 'returns a success code' do
        pending 'not implemented yet'
        get '/api/v1/reference/move_detail_types', headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        pending 'not implemented yet'
        get '/api/v1/reference/move_detail_types', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending 'not implemented yet'
        get '/api/v1/reference/move_detail_types', headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'fails if I set the wrong `content-type` header' do
        pending 'not implemented yet'
        get '/api/v1/reference/move_detail_types', headers: headers
        expect(response.code).to eql '415'
      end
    end

    describe 'filtering'

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_move_detail_types_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          pending 'not implemented yet'
          get '/api/v1/reference/move_detail_types', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          pending 'not implemented yet'
          get '/api/v1/reference/move_detail_types', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end
    end
  end
end
