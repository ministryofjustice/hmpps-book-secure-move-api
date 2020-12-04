# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PopulationsController do
  describe 'PATCH /populations/:population_id' do
    include_context 'with supplier with spoofed access token'

    subject(:patch_population) do
      patch "/api/populations/#{population_id}", params: population_params, headers: headers, as: :json
    end

    let(:schema) { load_yaml_schema('patch_population_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:population) { create(:population) }
    let(:population_id) { population.id }
    let(:population_attributes) do
      {
        date: Date.tomorrow.iso8601,
        operational_capacity: 200,
        usable_capacity: 195,
        unlock: 180,
        bedwatch: 3,
        overnights_in: 6,
        overnights_out: 2,
        out_of_area_courts: 1,
        discharges: 7,
        updated_by: 'Fulton McKay',
      }
    end
    let(:population_params) do
      {
        data: {
          type: 'populations',
          attributes: population_attributes,
        },
      }
    end

    context 'when successful' do
      before { patch_population }

      context 'when location is not specified' do
        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            id: population_id,
            type: 'populations',
            attributes: population_attributes,
          })
        end
      end

      context 'when location is specified' do
        let(:location) { create :location, :prison }
        let(:population_params) do
          {
            data: {
              type: 'populations',
              attributes: population_attributes,
              relationships: {
                location: { data: { type: 'locations', id: location.id } },
              },
            },
          }
        end

        it 'updates population location' do
          expect(population.reload.location).to eq(location)
        end
      end
    end

    context 'when unsuccessful' do
      before { patch_population }

      context 'with a bad request' do
        let(:population_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with an invalid location' do
        let(:detail_404) { "Couldn't find Location with 'id'=fubar" }
        let(:population_params) do
          {
            data: {
              type: 'populations',
              attributes: population_attributes,
              relationships: {
                location: { data: { type: 'locations', id: 'fubar' } },
              },
            },
          }
        end

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'when the population_id is not found' do
        let(:population_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Population with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
