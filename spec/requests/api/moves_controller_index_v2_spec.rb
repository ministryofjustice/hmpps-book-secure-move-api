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
          from_location_id: from_location_id,
          foo: 'foo',
        }
      end
      let(:params) { { filter: filters } }

      it 'delegates the query execution to Moves::Finder with the correct filters' do
        ability = instance_double('Ability')
        allow(Ability).to receive(:new).and_return(ability)

        moves_finder = instance_double('Moves::Finder', call: Move.all)
        allow(Moves::Finder).to receive(:new).and_return(moves_finder)

        do_get

        expect(Moves::Finder).to have_received(:new).with(
          filter_params: { from_location_id: from_location_id },
          ability: ability,
          order_params: {},
          active_record_relationships: nil,
          included_relationships: nil,
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
      let!(:moves) { [move] }
      let(:from_location_id) { move.from_location_id }
      let(:filters) { { from_location_id: from_location_id } }
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
      let!(:moves) { [move] }
      let(:from_location_id) { move.from_location_id }
      let(:filters) { { from_location_id: from_location_id } }
      let(:params) { { filter: filters } }

      it 'returns the correct attributes values for moves' do
        do_get
        expect(response_json).to include_json(
          data: [{ id: move.id }],
        )
      end
    end

    describe 'paginating results' do
      let!(:moves) { create_list :move, 6 }

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

      before { do_get }

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
          from_location: from_location,
          to_location: to_location,
        )
      end

      let!(:court_hearing) { create(:court_hearing, move: moves.first) }

      let(:to_location) { create(:location, suppliers: [supplier]) }
      let(:from_location) { create(:location, suppliers: [supplier]) }

      before do
        get "/api/moves#{query_params}", params: params, headers: headers
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
  end

  def do_get
    get '/api/moves', params: params, headers: headers
  end
end
