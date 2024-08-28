# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ExtraditionFlightController do
  describe 'PATCH /moves/:move_id/extradition_flight/:extradition_flight_id' do
    subject(:do_patch) do
      patch "/api/moves/#{move_id}/extradition_flight/#{extradition_flight.id}", params:, headers:, as: :json
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
    let(:extradition_flight) { create(:extradition_flight, flight_number: 'AA0234', flight_time: '2024-01-01', move:) }

    let(:params) do
      {
        data: {
          type: 'extradition_flight',
          attributes: {
            flight_number:,
            flight_time:,
          },
          relationships: {
            move: {
              data: {
                id: move_id,
                type: 'moves',
              },
            },
          },
        },
      }
    end

    context 'when successful' do
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

      let(:schema) { load_yaml_schema('patch_extradition_flight_responses.yaml') }

      it_behaves_like 'an endpoint that responds with success 200' do
        before { do_patch }
      end

      it 'returns the correct data' do
        do_patch
        expect(response_json).to include_json(data:)
      end

      it 'updates the flight number in the database' do
        do_patch
        expect(extradition_flight.reload.flight_number).to eq(flight_number)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with an invalid flight time' do
        let(:flight_time) { '9999-A1-02' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_patch }

          let(:errors_422) do
            [
              {
                'title' => 'Unprocessable content',
                'detail' => 'Flight time must be formatted as a valid iso-8601 date',
              },
            ]
          end
        end
      end

      context 'with a bad request' do
        let(:params) { nil }

        it_behaves_like 'an endpoint that responds with error 400' do
          before { do_patch }
        end
      end

      context 'when the move_id is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404' do
          before do
            do_patch
          end
        end
      end
    end
  end
end
