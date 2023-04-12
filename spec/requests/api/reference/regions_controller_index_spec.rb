# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::RegionsController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'Authorization' => "Bearer #{access_token}" } }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/regions' do
    let(:schema) { load_yaml_schema('get_regions_responses.yaml') }

    let(:location) { create(:location) }
    let!(:region1) { create(:region, locations: [location]) }
    let!(:region2) { create(:region, locations: [location]) }

    before do
      get '/api/v1/reference/regions', headers: headers
    end

    context 'when successful' do
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

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'with multiple locations' do
      let(:location1) { create(:location) }
      let(:location2) { create(:location) }
      let(:location3) { create(:location) }

      let!(:region1) { create(:region, locations: [location1, location2]) }
      let!(:region2) { create(:region, locations: [location2, location3]) }
      let(:expected_relationships) do
        UnorderedArray(
          {
            relationships: {
              locations: {
                data: UnorderedArray(
                  { id: location1.id, type: 'locations' },
                  id: location2.id,
                  type: 'locations',
                ),
              },
            },
          },
          relationships: {
            locations: {
              data: UnorderedArray(
                { id: location2.id, type: 'locations' },
                id: location3.id,
                type: 'locations',
              ),
            },
          },
        )
      end

      it 'has correct relationships for each location' do
        expect(response_json).to include_json(data: expected_relationships)
      end
    end
  end
end
