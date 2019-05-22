# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::LocationsController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'GET /api/v1/reference/locations' do
    let(:expected_data) do
      [
        {
          type: 'locations',
          attributes: {
            description: 'Guildford Crown Court',
            location_type: 'court',
            location_code: 'GCC'
          }
        },
        {
          type: 'locations',
          attributes: {
            description: 'HMP Pentonville',
            location_type: 'prison',
            location_code: 'PEI'
          }
        }
      ]
    end

    context 'with the correct CONTENT_TYPE header' do
      it 'returns a success code' do
        pending 'not implemented yet'
        get '/api/v1/reference/locations', headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        pending 'not implemented yet'
        get '/api/v1/reference/locations', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending 'not implemented yet'
        get '/api/v1/reference/locations', headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'fails if I set the wrong `content-type` header' do
        pending 'not implemented yet'
        get '/api/v1/reference/locations', headers: headers
        expect(response.code).to eql '415'
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_locations_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          pending 'not implemented yet'
          get '/api/v1/reference/locations', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          pending 'not implemented yet'
          get '/api/v1/reference/locations', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end
end
