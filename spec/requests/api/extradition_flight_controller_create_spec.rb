# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FlightDetailsController do
  describe 'POST /moves/:move_id/extradition_flight' do
    subject(:do_post) do
      post "/api/moves/#{move_id}/extradition_flight", params:, headers:, as: :json
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
    let(:flight_time) { '2020-05-04' }

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
          id: FlightDetails.last.id,
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

      let(:schema) { load_yaml_schema('post_extradition_flight_responses.yaml') }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'returns the correct data' do
        do_post
        expect(response_json).to include_json(data:)
      end

      it 'creates the extradition flight in the DB' do
        do_post
        expect(move.extradition_flight.attributes.symbolize_keys.slice(:flight_number, :flight_time, :move_id)).to eq({
          flight_number:,
          flight_time:,
          move_id:,
        })
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with an invalid flight time' do
        let(:flight_time) { '9999-A1-02' }

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }

          let(:errors_422) do
            [
              {
                'title' => 'Unprocessable entity',
                'detail' => 'Flight time must be formatted as a valid iso-8601 date',
              },
            ]
          end
        end
      end

      context 'with a bad request' do
        let(:params) { nil }

        it_behaves_like 'an endpoint that responds with error 400' do
          before { do_post }
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
    end
  end
end
