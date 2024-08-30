# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ExtraditionFlightController do
  describe 'GET /moves/:move_id/extradition_flight' do
    subject(:do_get) do
      get "/api/moves/#{move_id}/extradition_flight", headers:, as: :json
    end

    let(:headers) do
      {
        'CONTENT_TYPE': content_type,
        'Accept': 'application/vnd.api+json; version=2',
        'Authorization' => "Bearer #{access_token}",
        'X-Current-User' => 'TEST_USER',
        'Idempotency-Key' => SecureRandom.uuid,
      }
    end

    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('post_moves_responses.yaml', version: 'v2') }
    let(:supplier) { create(:supplier) }
    let(:access_token) { 'spoofed-token' }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:move) { create(:move, supplier:) }
    let(:move_id) { move.id }
    let(:flight_number) { 'BA0123' }
    let(:flight_time) { '2024-01-01' }

    context 'when an extradition flight exists' do
      let!(:extradition_flight) { create(:extradition_flight, flight_number:, flight_time:, move:) }

      let(:data) do
        {
          id: extradition_flight.id,
          type: 'extradition_flight',
          attributes: {
            flight_number:,
            flight_time:,
          },
          relationships: {
            move: {
              data: {
                id: move.id,
                type: 'moves',
              },
            },
          },
        }
      end

      let(:schema) { load_yaml_schema('get_extradition_flight_responses.yaml') }

      it_behaves_like 'an endpoint that responds with success 200' do
        before { do_get }
      end

      it 'returns the correct data' do
        do_get
        expect(response_json).to include_json(data:)
      end

      it 'updates the flight number in the database' do
        do_get
        expect(extradition_flight.reload.flight_number).to eq(flight_number)
      end

      describe 'with included move' do
        let(:params) do
          { include: 'move' }
        end

        it 'includes the requested includes in the response' do
          do_get
          returned_types = response_json['data']['relationships']
          expect(returned_types).to eq({
            'move' => {
              'data' => {
                'id' => move_id,
                'type' => 'moves',
              },
            },
          })
        end
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when the move_id is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_get
          end
        end
      end

      context 'when there is no extradition flight associated with the move' do
        let(:detail_404) { "Couldn't find ExtraditionFlight with [WHERE \"extradition_flights\".\"move_id\" = $1]" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_get
          end
        end
      end
    end
  end
end
