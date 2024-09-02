# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:accept) { 'application/vnd.api+json; version=2' }
  let(:schema) { load_yaml_schema('get_moves_responses.yaml', version: 'v2') }
  let(:params) { {} }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': accept,
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /moves' do
    let!(:moves) { create_list :move, 2 }

    it_behaves_like 'an endpoint that responds with success 200' do
      before { do_get }
    end

    describe 'filtering results' do
      let(:from_location_id) { moves.first.from_location_id }
      let(:filters) do
        {
          bar: 'bar',
          from_location_id:,
          foo: 'foo',
        }
      end
      let(:params) { { filter: filters } }

      it 'delegates the query execution to Moves::Finder with the correct filters' do
        ability = instance_double(Ability)
        allow(Ability).to receive(:new).and_return(ability)

        moves_finder = instance_double(Moves::Finder, call: Move.all)
        allow(Moves::Finder).to receive(:new).and_return(moves_finder)

        do_get

        expect(Moves::Finder).to have_received(:new).with(
          filter_params: { from_location_id: },
          ability:,
          order_params: {},
          active_record_relationships: nil,
        )
      end

      it 'filters the results' do
        do_get

        expect(response_json['data'].size).to be 1
      end

      it 'returns the move that matches the filter' do
        do_get

        expect(response_json).to include_json(data: [{ id: moves.first.id }])
      end
    end

    context 'with a cancelled move' do
      let(:move) { create(:move, :cancelled) }
      let(:from_location_id) { move.from_location_id }
      let(:filters) { { from_location_id: } }
      let(:params) { { filter: filters } }
      let(:expected_move) do
        {
          data: [
            {
              id: move.id,
              attributes: {
                cancellation_reason: move.cancellation_reason,
                cancellation_reason_comment: move.cancellation_reason_comment,
              },
            },
          ],
        }
      end

      it 'returns the correct attributes values for moves' do
        do_get

        expect(response_json).to include_json(expected_move)
      end
    end

    context 'with a booked move' do
      let(:move) { create(:move, :booked) }
      let(:from_location_id) { move.from_location_id }
      let(:filters) { { from_location_id: } }
      let(:params) { { filter: filters } }

      it 'returns the correct attributes values for moves' do
        do_get
        expect(response_json).to include_json(
          data: [{ id: move.id }],
        )
      end
    end

    describe 'paginating results' do
      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
        }
      end
      let(:pagination_links) do
        {
          self: 'http://www.example.com/api/moves?page=1&per_page=5',
          first: 'http://www.example.com/api/moves?page=1&per_page=5',
          prev: nil,
          next: 'http://www.example.com/api/moves?page=2&per_page=5',
          last: 'http://www.example.com/api/moves?page=2&per_page=5',
        }
      end

      before do
        create_list :move, 4
        do_get
      end

      it_behaves_like 'an endpoint that paginates resources'
    end

    context 'when date_from is invalid' do
      let(:from_location) { moves.first.from_location }
      let(:filters) do
        {
          from_location_id: from_location.id,
          date_from: 'yyyy-09-Tu',
        }
      end
      let(:params) { { filter: filters } }

      before { do_get }

      it_behaves_like 'an endpoint that responds with error 422' do
        let(:errors_422) do
          [{ 'title' => 'Invalid date_from',
             'detail' => 'Validation failed: Date from is not a valid date.' }]
        end
      end
    end

    describe 'included relationships' do
      let!(:moves) do
        create_list(
          :move,
          1,
          from_location:,
          to_location:,
        )
      end

      let(:to_location) { create(:location, suppliers: [supplier]) }
      let(:from_location) { create(:location, suppliers: [supplier]) }

      before do
        create(:court_hearing, move: moves.first)
        do_get(query_params)
      end

      context 'when not including the include query param' do
        let(:query_params) { '' }

        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:query_params) { '?include=profile' }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('profiles')
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

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to include(expected_error)
        end
      end
    end

    describe 'meta fields' do
      let(:notification_events) do
        [
          create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-17T10:20:30+01:00'),
          create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-19T10:20:30+01:00'),
        ]
      end

      before do
        create_list(
          :move,
          1,
          :with_journey,
          notification_events:,
        )

        do_get(query_params)
      end

      context 'when not including the meta query param' do
        let(:query_params) { '' }

        it 'returns an empty meta section' do
          move = response_json['data'].first
          expect(move['meta']).to be_empty
        end
      end

      context 'when including the meta query param' do
        let(:query_params) { '?meta=vehicle_registration,expected_time_of_arrival,expected_collection_time' }

        it 'includes the requested meta fields in the response' do
          move = response_json['data'].first
          expect(move['meta']).to eq(
            'vehicle_registration' => 'AB12 CDE',
            'expected_time_of_arrival' => '2019-06-19T10:20:30+01:00',
            'expected_collection_time' => '2019-06-17T10:20:30+01:00',
          )
        end
      end
    end
  end

  def do_get(query_params = nil)
    get "/api/moves#{query_params}", params:, headers:
  end
end
