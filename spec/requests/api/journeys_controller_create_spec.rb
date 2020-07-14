# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneysController do
  describe 'POST /moves/:move_id/journeys' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:from_location_id) { create(:location, suppliers: [supplier]).id }
    let(:to_location_id) { create(:location, suppliers: [supplier]) .id }
    let(:move_id) { create(:move, supplier: supplier).id }
    let(:timestamp) { '2020-05-04T09:00:00+01:00' }
    let(:billable) { false }

    let(:journey_params) do
      {
        data: {
          "type": 'journeys',
          "attributes": {
            "billable": billable,
            "timestamp": timestamp,
            "vehicle": { "id": '12345678ABC', "registration": 'AB12 CDE' },
          },
          "relationships": {
            "from_location": {
              "data": {
                "id": from_location_id,
                "type": 'locations',
              },
            },
            "to_location": {
              "data": {
                "id": to_location_id,
                "type": 'locations',
              },
            },
          },
        },
      }
    end

    before do
      post "/api/v1/moves/#{move_id}/journeys", params: journey_params, headers: headers, as: :json
    end

    context 'when successful' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }
      let(:schema) { load_yaml_schema('post_journeys_responses.yaml') }
      let(:data) do
        {
          "id": Journey.first&.id,
          "type": 'journeys',
          "attributes": {
            "billable": false,
            "state": 'proposed',
            "timestamp": '2020-05-04T09:00:00+01:00',
            "vehicle": { "id": '12345678ABC', "registration": 'AB12 CDE' },
          },
          "relationships": {
            "from_location": {
              "data": {
                "id": from_location_id,
                "type": 'locations',
              },
            },
            "to_location": {
              "data": {
                "id": to_location_id,
                "type": 'locations',
              },
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with a bad request' do
        let(:journey_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with an invalid timestamp' do
        let(:timestamp) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid timestamp',
               'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }]
          end
        end
      end

      context 'with an invalid billable' do
        let(:billable) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid billable',
               'detail' => 'Validation failed: Billable is not included in the list' }]
          end
        end
      end

      context 'when the move_id is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with a reference to a missing relationship' do
        let(:to_location_id) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid location',
               'detail' => 'Validation failed: Location reference was not found id=foo-bar' }]
          end
        end
      end
    end
  end
end
