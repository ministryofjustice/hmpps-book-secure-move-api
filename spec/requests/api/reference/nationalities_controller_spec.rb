# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::NationalitiesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'GET /api/v1/reference/nationalities' do
    let(:schema) { load_yaml_schema('get_nationalities_responses.yaml') }

    let(:data) do
      [
        {
          type: 'nationalities',
          attributes: {
            key: 'british',
            title: 'British',
          },
        },
        {
          type: 'nationalities',
          attributes: {
            key: 'french',
            title: 'French',
          },
        },
      ]
    end

    before do
      data.each { |nationality| Nationality.create!(nationality[:attributes]) }
    end

    context 'when successful' do
      before do
        get '/api/v1/reference/nationalities', headers: headers
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:detail_401) { 'Token expired or invalid' }
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }

      before do
        get '/api/v1/reference/nationalities', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before do
        get '/api/v1/reference/nationalities', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
