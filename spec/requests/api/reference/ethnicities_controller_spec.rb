# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::EthnicitiesController do
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'GET /api/v1/reference/ethnicities' do
    let(:schema) { load_yaml_schema('get_ethnicities_responses.yaml') }

    let(:data) do
      [
        {
          type: 'ethnicities',
          attributes: {
            key: 'W1',
            title: 'White British',
            description: 'W1 - White British',
          },
        },
        {
          type: 'ethnicities',
          attributes: {
            key: 'A1',
            title: 'Asian or Asian British (Indian)',
            description: 'A1 - Asian or Asian British (Indian)',
          },
        },
      ]
    end

    before do
      data.each { |ethnicity| Ethnicity.create!(ethnicity[:attributes]) }
    end

    context 'when successful' do
      before do
        get '/api/v1/reference/ethnicities', headers: headers
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }
      let(:detail_401) { 'Token expired or invalid' }

      before do
        get '/api/v1/reference/ethnicities', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before do
        get '/api/v1/reference/ethnicities', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
