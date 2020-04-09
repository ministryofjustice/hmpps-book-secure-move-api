# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  let(:supplier) { create(:supplier) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let!(:access_token) { create(:access_token, application: application).token }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /moves' do
    let(:schema) { load_json_schema('get_moves_responses.json') }

    let!(:moves) { create_list :move, 21 }
    let(:params) { {} }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/moves', params: params, headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

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

        before do
          allow(Ability).to receive(:new).and_return(ability)
        end

        it 'delegates the query execution to Moves::Finder with the correct filters', skip_before: true do
          moves_finder = instance_double('Moves::Finder', call: Move.all)
          allow(Moves::Finder).to receive(:new).and_return(moves_finder)

          get '/api/v1/moves', headers: headers, params: params

          expect(Moves::Finder).to have_received(:new).with({ from_location_id: from_location_id }, ability, {})
        end

        it 'filters the results' do
          expect(response_json['data'].size).to be 1
        end

        it 'returns the move that matches the filter' do
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

        # rubocop:disable RSpec/ExampleLength
        it 'returns the correct attributes values for moves' do
          expect(response_json).to include_json(
            data: [
              {
                id: move.id,
                attributes: {
                  cancellation_reason: move.cancellation_reason,
                  cancellation_reason_comment: move.cancellation_reason_comment,
                },
              },
            ],
            )
        end
        # rubocop:enable RSpec/ExampleLength
      end

      describe 'paginating results' do
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

        it 'paginates 20 results per page' do
          expect(response_json['data'].size).to eq 20
        end

        it 'returns 1 result on the second page', skip_before: true do
          get '/api/v1/moves?page=2', headers: headers

          expect(response_json['data'].size).to eq 1
        end

        it 'allows setting a different page size', skip_before: true do
          get '/api/v1/moves?per_page=15', headers: headers

          expect(response_json['data'].size).to eq 15
        end

        it 'provides meta data with pagination', skip_before: true do
          get '/api/v1/moves', headers: headers

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

        before do
          get '/api/v1/moves', params: params, headers: headers
        end

        it 'is a bad request' do
          expect(response.status).to eq(400)
        end

        it 'returns errors' do
          expect(response.body).to eq('{"error":{"date_from":["is not a valid date."]}}')
        end
      end

      describe 'relationships' do
        let!(:moves) { [create(:move)] }
        let!(:court_hearing) { create(:court_hearing, move: moves.first) }

        it 'does not return serialized court_hearings includes', skip_before: true do
          get '/api/v1/moves', params: params, headers: headers

          has_court_hearings = response_json['included'].any? do |entity|
            entity['type'] == 'court_hearings'
          end

          expect(has_court_hearings).to eq(false)
        end
      end
    end

    context 'when not authorized', :skip_before, :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:detail_401) { 'Token expired or invalid' }

      before do
        get '/api/v1/moves', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
