# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::NationalitiesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }

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
    let(:schema) { load_json_schema('get_nationalities_responses.json') }
    let(:response_json) { JSON.parse(response.body) }

    before do
      create :nationality
      create :nationality, :french

      get '/api/v1/reference/nationalities', headers: headers
    end

    context 'with the correct CONTENT_TYPE header' do
      it 'returns a success code' do
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        expect(JSON.parse(response.body)).to include_json(data: data)
      end

      it 'sets the correct content type header' do
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it 'fails if I set the wrong `content-type` header' do
        expect(response.code).to eql '415'
      end
    end

    describe 'response schema validation', with_json_schema: true do
      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:content_type) { 'application/xml' }

        it 'returns a valid 415 JSON response' do
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end
end
