# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::MovesController do
  subject(:post_moves) do
    post '/api/moves/filtered', params: { data: data }.merge(params), headers: headers, as: :json
  end

  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:accept) { 'application/vnd.api+json; version=2' }
  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': accept,
      'Authorization' => "Bearer #{access_token}",
    }
  end

  let(:data) do
    {
      type: 'moves',
      attributes: attributes,
    }
  end

  describe 'post /moves' do
    let(:attributes) { {} }
    let(:params) { {} }
    let(:schema) { load_yaml_schema('post_moves_filtered_responses.yaml', version: 'v2') }
    let!(:moves) { create_list :move, 2 }

    it_behaves_like 'an endpoint that responds with success 200' do
      before { post_moves }
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
      let(:attributes) { { filter: filters } }

      it 'filters the results' do
        post_moves

        expect(response_json['data'].size).to be 1
      end

      it 'returns the move that matches the filter' do
        post_moves

        expect(response_json).to include_json(data: [{ id: moves.first.id }])
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
          self: 'http://www.example.com/api/moves/filtered?page=1&per_page=5',
          first: 'http://www.example.com/api/moves/filtered?page=1&per_page=5',
          prev: nil,
          next: 'http://www.example.com/api/moves/filtered?page=2&per_page=5',
          last: 'http://www.example.com/api/moves/filtered?page=2&per_page=5',
        }
      end

      before { post_moves }

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
      let(:attributes) { { filter: filters } }

      before { post_moves }

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

      before { post_moves }

      context 'when not including the include query param' do
        let(:params) { {} }

        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:params) { { include: 'profile' } }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('profiles')
        end
      end

      context 'when including an invalid include query param' do
        let(:params) { { include: 'foo.bar,profile' } }

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
      let(:events) do
        [
          create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-17T10:20:30+01:00'),
          create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-19T10:20:30+01:00'),
        ]
      end
      let!(:moves) do
        create_list(
          :move,
          1,
          :with_journey,
          generic_events: events,
        )
      end

      before { post_moves }

      context 'when not including the meta query param' do
        let(:params) { {} }

        it 'returns an empty meta section' do
          move = response_json['data'].first
          expect(move['meta']).to be_empty
        end
      end

      context 'when including the meta query param' do
        let(:params) { { meta: 'vehicle_registration,expected_time_of_arrival,expected_collection_time' } }

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
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
