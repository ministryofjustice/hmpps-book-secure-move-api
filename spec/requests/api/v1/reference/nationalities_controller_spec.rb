# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::Reference::NationalitiesController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'GET /api/v1/reference/nationalities' do
    let(:data) do
      [
        {
          type: 'nationalities',
          attributes: {
            title: 'British'
          }
        },
        {
          type: 'nationalities',
          attributes: {
            title: 'French'
          }
        }
      ]
    end

    before do
      create :nationality
      create :nationality, :french
    end

    context 'with the correct CONTENT_TYPE header' do
      it 'returns a success code' do
        get '/api/v1/reference/nationalities', headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        get '/api/v1/reference/nationalities', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: data)
      end

      it 'sets the correct content type header' do
        get '/api/v1/reference/nationalities', headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'fails if I set the wrong `content-type` header' do
        get '/api/v1/reference/nationalities', headers: headers
        expect(response.code).to eql '415'
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_nationalities_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          get '/api/v1/reference/nationalities', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          get '/api/v1/reference/nationalities', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end
end
