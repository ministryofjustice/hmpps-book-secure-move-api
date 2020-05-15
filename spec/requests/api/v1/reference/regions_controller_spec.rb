# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::RegionsController do
  let!(:access_token) { create(:access_token).token }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'GET /api/v1/reference/regions' do
    let(:schema) { load_yaml_schema('get_regions_responses.yaml') }

    let(:location) { create(:location) }
    let!(:region1) { create(:region, locations: [location]) }
    let!(:region2) { create(:region, locations: [location]) }

    let(:data) do
      [
        {
          type: 'regions',
          attributes: {
            key: region1.key,
            name: region1.name,
          },
          relationships: {
            locations: {
              data: [
                {
                  id: location.id,
                  type: 'locations',
                },
              ],
            },
          },
        },
        {
          type: 'regions',
          attributes: {
            key: region2.key,
            name: region2.name,
          },
          relationships: {
            locations: {
              data: [
                {
                  id: location.id,
                  type: 'locations',
                },
              ],
            },
          },
        },
      ]
    end

    before do
      get '/api/v1/reference/regions', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
