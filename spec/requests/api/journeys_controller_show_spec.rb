# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneysController do
  describe 'GET /moves/:move_id/journeys/:journey_id' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:locations) { create_list(:location, 2, suppliers: [supplier]) }
    let(:move) { create(:move, from_location: locations.first, to_location: locations.last, supplier:) }
    let(:journey) { create(:journey, move:, supplier:, client_timestamp: '2020-05-04T08:00:00Z', from_location: locations.first, to_location: locations.last) }

    before do
      get "/api/v1/moves/#{move.id}/journeys/#{journey.id}", headers:, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('get_journey_responses.yaml') }
      let(:data) do
        {
          "id": journey.id,
          "type": 'journeys',
          "attributes": {
            "billable": false,
            "state": 'proposed',
            "timestamp": '2020-05-04T09:00:00+01:00',
            "vehicle": {
              "id": '12345678ABC',
              "registration": 'AB12 CDE',
            },
          },
          "relationships": {
            "from_location": {
              "data": {
                "id": locations.first.id,
                "type": 'locations',
              },
            },
            "to_location": {
              "data": {
                "id": locations.last.id,
                "type": 'locations',
              },
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context "when attempting to access another supplier's journey" do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application:).token }
        let(:journey) { create(:journey, move:) } # another journey for a different supplier, same move
        let(:detail_401) { 'Not authorized' }

        it_behaves_like 'an endpoint that responds with error 401'
      end

      context "when attempting to access another move's journey" do
        let(:journey) { create(:journey, supplier:) } # another journey for a different move, same supplier
        let(:detail_404) { "Couldn't find Journey with 'id'=#{journey.id}" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
