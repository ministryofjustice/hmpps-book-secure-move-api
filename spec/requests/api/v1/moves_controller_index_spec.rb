# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  subject(:get_moves) { get '/api/v1/moves', params: params, headers: headers }

  let(:supplier) { create(:supplier) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let!(:access_token) { create(:access_token, application: application).token }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /moves' do
    let(:schema) { load_yaml_schema('get_moves_responses.yaml') }

    let!(:moves) { create_list :move, 2 }
    let(:params) { {} }

    context 'when no params are provided' do
      before { get_moves }

      it_behaves_like 'an endpoint that responds with success 200'
    end

    context 'when called with correct params' do
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
        let(:ability) { Ability.new }

        it 'delegates the query execution to Moves::Finder with the correct filters' do
          allow(Ability).to receive(:new).and_return(ability)

          moves_finder = instance_double('Moves::Finder', call: Move.all)
          allow(Moves::Finder).to receive(:new).and_return(moves_finder)

          get_moves

          expect(Moves::Finder).to have_received(:new).with({ from_location_id: from_location_id }, ability, {})
        end

        it 'filters the results' do
          get_moves

          expect(response_json['data'].size).to be 1
        end

        it 'returns the move that matches the filter' do
          get_moves

          expect(response_json).to include_json(data: [{ id: moves.first.id }])
        end
      end

      context 'with a cancelled move' do
        let(:move) { create(:move, :cancelled) }
        let!(:moves) { [move] }
        let(:from_location_id) { move.from_location_id }
        let(:filters) do
          {
            from_location_id: from_location_id,
          }
        end
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
          get_moves

          expect(response_json).to include_json(expected_move)
        end
      end

      describe 'paginating results' do
        let!(:moves) { create_list :move, 21 }

        let(:meta_pagination) do
          {
            per_page: 20,
            total_pages: 2,
            total_objects: 21,
            links: {
              first: '/api/v1/moves?page=1',
              last: '/api/v1/moves?page=2',
              next: '/api/v1/moves?page=2',
            },
          }
        end

        it 'paginates 20 results per page as default' do
          get_moves

          expect(response_json['data'].size).to eq 20
        end

        it 'returns 1 result on the second page'  do
          get '/api/v1/moves?page=2', headers: headers

          expect(response_json['data'].size).to eq 1
        end

        it 'allows setting a different page size' do
          get '/api/v1/moves?per_page=15', headers: headers

          expect(response_json['data'].size).to eq 15
        end

        it 'provides meta data with pagination' do
          get_moves

          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      describe 'validating dates before running queries' do
        let(:from_location) { moves.first.from_location }
        let(:filters) do
          {
            from_location_id: from_location.id,
            date_from: 'yyyy-09-Tu',
          }
        end
        let(:params) { { filter: filters } }

        before { get_moves }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid date_from',
               'detail' => 'Validation failed: Date from is not a valid date.' }]
          end
        end
      end

      describe 'included relationships' do
        let!(:moves) { create_list(:move, 1) }
        let!(:court_hearing) { create(:court_hearing, move: moves.first) }

        before do
          get "/api/v1/moves#{query_params}", params: params, headers: headers
        end

        context 'when not including the include query param' do
          let(:query_params) { '' }

          it 'returns the default includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('ethnicities', 'genders', 'locations', 'people', 'profiles')
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

      context 'when the move includes both a profile id and a person id' do
        let(:person) { create(:person) }
        let!(:move) { create(:move, person_id: person.id, profile_id: person.latest_profile.id) }

        it 'returns the correct person' do
          get_moves
          person_id = response_json['data'][0].dig('relationships', 'person', 'data', 'id')
          expect(person_id).to eq(person.id)
        end
      end

      context 'when the move includes neither profile id or person id' do
        let!(:move) { create(:move, person_id: nil, profile_id: nil) }

        it 'returns the correct person' do
          get_moves
          person_id = response_json['data'][0].dig('relationships', 'person', 'data', 'id')
          expect(person_id).to be_nil
        end
      end

      context 'when the move includes only a person id' do
        let(:person) { create(:person) }
        let!(:move) { create(:move, person_id: person.id, profile_id: nil) }

        it 'returns the correct person' do
          get_moves
          person_id = response_json['data'][0].dig('relationships', 'person', 'data', 'id')
          expect(person_id).to eq(person.id)
        end
      end

      context 'when the move includes only a profile id' do
        let(:person) { create(:person) }
        let!(:move) { create(:move, person_id: nil, profile_id: person.latest_profile.id) }

        it 'returns the correct person' do
          get_moves
          person_id = response_json['data'][0].dig('relationships', 'person', 'data', 'id')
          expect(person_id).to eq(person.id)
        end
      end
    end

    context 'when not authorized', :skip_before, :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:detail_401) { 'Token expired or invalid' }

      before { get_moves }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { get_moves }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
