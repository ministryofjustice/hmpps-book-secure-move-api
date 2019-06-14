# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_DETAIL))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'GET /moves' do
    let(:schema) { load_json_schema('get_moves_responses.json') }

    let!(:moves) { create_list :move, 21 }
    let(:params) { {} }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/moves', headers: headers, params: params
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      describe 'filtering results' do
        let(:from_location_id) { moves.first.from_location_id }
        let(:filters) do
          {
            bar: 'bar',
            from_location_id: from_location_id,
            foo: 'foo'
          }
        end
        let(:params) { { filter: filters } }

        it 'delegates the query execution to Moves::Finder with the correct filters', skip_before: true do
          moves_finder = instance_double('Moves::Finder', call: Move.all)
          allow(Moves::Finder).to receive(:new).and_return(moves_finder)

          get '/api/v1/moves', headers: headers, params: params

          expect(Moves::Finder).to have_received(:new).with(from_location_id: from_location_id)
        end

        it 'filters the results' do
          expect(response_json['data'].size).to be 1
        end

        it 'returns the move that matches the filter' do
          expect(response_json).to include_json(data: [{ id: moves.first.id }])
        end
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
              next: '/api/v1/moves?page=2'
            }
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

        it 'provides meta data with pagination' do
          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end

  describe 'GET /moves/{moveId}' do
    let(:schema) { load_json_schema('get_move_responses.json') }

    let!(:move) { create :move }
    let(:move_id) { move.id }

    before { get "/api/v1/moves/#{move_id}", headers: headers }

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when resource is not found' do
      let(:move_id) { 'UUID-not-found' }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end

  describe 'POST /moves' do
    let(:schema) { load_json_schema('post_moves_responses.json') }

    let(:move_attributes) { attributes_for(:move) }
    let!(:from_location) { create :location }
    let!(:to_location) { create :location, :court }
    let!(:person) { create(:person) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          person: { data: { type: 'people', id: person.id } },
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: { data: { type: 'locations', id: to_location.id } }
        }
      }
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
    end

    context 'when successful' do
      let(:move) { Move.first }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'creates a move', skip_before: true do
        expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
          .to change(Move, :count).by(1)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with a reference to a missing relationship' do
      let(:person) { Person.new }
      let(:detail_404) { "Couldn't find Person without an ID" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'invalid') }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank'
          },
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Status is not included in the list',
            'source' => { 'pointer' => '/data/attributes/status' },
            'code' => 'inclusion'
          }
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end

  describe 'DELETE /moves/{moveId}' do
    let(:schema) { load_json_schema('delete_move_responses.json') }

    let!(:move) { create :move }
    let(:move_id) { move.id }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      delete "/api/v1/moves/#{move_id}", headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'deletes the move', skip_before: true do
        expect { delete "/api/v1/moves/#{move_id}", headers: headers }
          .to change(Move, :count).by(-1)
      end

      it 'does not delete the person' do
        expect(Person.count).to be 1
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when resource is not found' do
      let(:move_id) { 'UUID-not-found' }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
