# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::ReligionsController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'GET /api/v1/reference/religions' do
    let(:expected_data) do
      [
        {
          id: 'ade88298-9727-4f1c-9f79-0e25657f2f28',
          title: 'Christian'
        },
        {
          id: '259c0156-8ae2-408e-898c-94f485492ab6',
          title: 'Hindu'
        },
        {
          id: 'fe28dbee-7395-4e28-b5bc-deeae3792867',
          title: 'Muslim'
        }
      ]
    end

    context 'with the correct CONTENT_TYPE header' do
      it 'returns a success code' do
        pending
        get '/api/v1/reference/religions', headers: headers
        expect(response).to be_successful
      end

      it 'returns an empty list' do
        pending
        get '/api/v1/reference/religions', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending
        get '/api/v1/reference/religions', headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'fails if I set the wrong `content-type` header' do
        pending
        get '/api/v1/reference/religions', headers: headers
        expect(response.code).to eql '415'
      end
    end
  end
end
