# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  subject(:do_get) { get "/api/moves/#{move.id}", params:, headers: }

  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:schema) { load_yaml_schema('get_move_responses.yaml', version: 'v2') }
  let(:params) { {} }

  let(:resource_to_json) do
    JSON.parse(V2::MoveSerializer.new(move).serializable_hash.to_json)
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /moves/:id' do
    let(:move) { create(:move) }

    it 'returns serialized data' do
      do_get
      expect(response_json).to eq resource_to_json
    end

    it_behaves_like 'an endpoint that responds with success 200' do
      before { do_get }
    end

    describe 'included relationships' do
      let(:profile) { create(:profile) }
      let(:court_hearing) { create(:court_hearing) }
      let(:to_location) { create(:location, suppliers: [supplier]) }
      let(:from_location) { create(:location, suppliers: [supplier]) }

      before do
        create(
          :move,
          profile:,
          from_location:,
          to_location:,
          court_hearings: [court_hearing],
        )

        create(:event_move_accept, eventable: move)
        create(:event_move_redirect, eventable: move)
      end

      context 'when not including the include query param' do
        let(:query_params) { '' }

        before { get "/api/moves/#{move.id}#{query_params}", params:, headers: }

        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:query_params) { '?include=profile' }

        before { get "/api/moves/#{move.id}#{query_params}", params:, headers: }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('profiles')
        end
      end

      context 'when including non-database fields' do
        let(:query_params) { '?include=timeline_events,timeline_events.to_location' }

        before { get "/api/moves/#{move.id}#{query_params}", params:, headers: }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('events', 'locations')
        end
      end

      context 'when including an invalid include query param' do
        let(:query_params) { '?include=foo.bar,profile' }

        let(:expected_error) do
          {
            'errors' => [
              {
                'detail' => match(/foo.bar/),
                'title' => 'Bad request',
              },
            ],
          }
        end

        before { get "/api/moves/#{move.id}#{query_params}", params:, headers: }

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to include(expected_error)
        end
      end

      context 'when including flight details' do
        let!(:flight_details) { create(:flight_details, move:) }
        let(:query_params) { '?include=flight_details' }

        before { get "/api/moves/#{move.id}#{query_params}", params:, headers: }

        it 'includes the flight details in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('flight_details')
        end
      end
    end
  end
end
