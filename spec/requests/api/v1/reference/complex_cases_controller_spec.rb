# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::ComplexCasesController do
  let!(:access_token) { create(:access_token).token }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'GET /api/v1/reference/complex_cases' do
    let(:schema) { load_json_schema('get_complex_cases_responses.json') }

    let(:data) do
      [
        {
          type: 'complex_cases',
          attributes: {
            key: 'mental',
            title: 'Mental Health Issues',
          },
        },
        {
          type: 'complex_cases',
          attributes: {
            key: 'other',
            title: 'Other Complex Case',
          },
        },
      ]
    end

    before do
      data.each { |complex_case| ComplexCase.create!(complex_case[:attributes]) }
    end

    context 'when successful' do
      before do
        get '/api/v1/reference/complex_cases', headers: headers
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
        get '/api/v1/reference/complex_cases', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before do
        get '/api/v1/reference/complex_cases', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
