# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::RegionsController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'Authorization' => "Bearer #{access_token}" } }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/regions/:id' do
    let(:schema) { load_yaml_schema('get_region_responses.yaml') }

    let(:location) { create(:location) }
    let!(:region) { create(:region, locations: [location]) }

    let(:data) do
      {
        type: 'regions',
        attributes: {
          key: region.key,
          name: region.name,
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
      }
    end

    before do
      get "/api/v1/reference/regions/#{region_id}", headers: headers
    end

    context 'when successful' do
      let(:region_id) { region.id }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when resource is not found' do
      let(:region_id) { 'ont-believe-it' }
      let(:detail_404) { "Couldn't find Region with 'id'=ont-believe-it" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
