# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::JourneysController do
  describe 'POST /moves/:move_id/journeys' do
    subject(:do_post) do
      post "/api/v1/moves/#{move_id}/journeys", params: journey_params, headers: headers, as: :json
    end

    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:from_location_id) { create(:location, suppliers: [supplier]).id }
    let(:to_location_id) { create(:location, suppliers: [supplier]).id }
    let(:alternate_from_location_id) { create(:location, suppliers: [supplier]).id }
    let(:alternate_to_location_id) { create(:location, suppliers: [supplier]).id }
    let(:move) { create(:move, supplier: supplier) }
    let(:move_id) { move.id }

    let(:timestamp) { '2020-05-04T09:00:00+01:00' }
    let(:billable) { false }
    let(:date) { '2020-05-04' }

    let(:journey_params) do
      {
        data: {
          "type": 'journeys',
          "attributes": {
            "billable": billable,
            "timestamp": timestamp,
            "date": date,
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

    context 'when successful' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }
      let(:schema) { load_yaml_schema('post_journeys_responses.yaml') }
      let(:data) do
        {
          "id": Journey.last&.id,
          "type": 'journeys',
          "attributes": {
            "billable": false,
            "state": 'proposed',
            "timestamp": '2020-05-04T09:00:00+01:00',
            "date": '2020-05-04',
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

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'returns the correct data' do
        do_post
        expect(response_json).to include_json(data: data)
      end

      it 'creates a JourneyCreate generic event' do
        expect { do_post }.to change(GenericEvent::JourneyCreate, :count).by(1)
      end

      it 'sets the created by on the GenericEvent' do
        do_post
        expect(GenericEvent.last.created_by).to eq('TEST_USER')
      end

      context 'with a missing date' do
        let(:date) { nil }

        it 'sets the date to the move date' do
          do_post
          expect(Journey.first.date).to eq(move.date)
        end
      end

      context 'when a move already has non-duplicate journeys' do
        before do
          create(:journey, :cancelled, move: move, from_location_id: from_location_id, to_location_id: to_location_id)
          create(:journey, :rejected, move: move, from_location_id: from_location_id, to_location_id: to_location_id)
          create(:journey, :completed, move: move, from_location_id: alternate_from_location_id, to_location_id: to_location_id)
          create(:journey, :completed, move: move, from_location_id: from_location_id, to_location_id: alternate_to_location_id)
        end

        it_behaves_like 'an endpoint that responds with success 201' do
          before { do_post }
        end

        it 'returns the correct data' do
          do_post
          expect(response_json).to include_json(data: data)
        end
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when you have duplicate journeys for a move' do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application: application).token }

        before do
          create(:journey, :completed, move: move, from_location_id: from_location_id, to_location_id: to_location_id)
          do_post
        end

        it 'returns bad request error code' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns errors in the body of the response' do
          expect(JSON.parse(response.body)).to include_json(errors: [
            {
              'title' => 'Bad request',
              'detail' => 'You are trying to submit a duplicate journey for this move, please try again',
            },
          ])
        end

        it 'returns a valid 400 JSON response' do
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/400')).to be true
        end

        it 'sets the correct content type header' do
          expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
        end
      end

      context 'with a bad request' do
        let(:journey_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400' do
          before { do_post }
        end
      end

      context 'with an invalid timestamp' do
        let(:timestamp) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [{ 'title' => 'Invalid timestamp',
               'detail' => 'Validation failed: Timestamp must be formatted as a valid ISO-8601 date-time' }]
          end
        end
      end

      context 'with an invalid billable' do
        let(:billable) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [{ 'title' => 'Invalid billable',
               'detail' => 'Validation failed: Billable is not included in the list' }]
          end
        end
      end

      context 'when the move_id is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_post
          end
        end
      end

      context 'with a reference to a missing relationship' do
        let(:to_location_id) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [{ 'title' => 'Invalid location',
               'detail' => 'Validation failed: Location reference was not found id=foo-bar' }]
          end
        end
      end
    end
  end
end
