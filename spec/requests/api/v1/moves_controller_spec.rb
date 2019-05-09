# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::MovesController do
  let(:valid_headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }
  let(:invalid_headers) { { 'CONTENT_TYPE': 'application/xml' } }

  describe 'GET /moves' do
    context 'when there is no data' do
      it 'returns a success code' do
        get '/api/v1/moves', headers: valid_headers
        expect(response).to be_successful
      end

      it 'returns an empty list' do
        get '/api/v1/moves', headers: valid_headers
        expect(JSON.parse(response.body)).to include_json(data: [])
      end

      it 'sets the correct content type header' do
        get '/api/v1/moves', headers: valid_headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end

      it 'fails if I set the wrong `content-type` header' do
        get '/api/v1/moves', headers: invalid_headers
        expect(response.code).to eql '415'
      end
    end

    context 'with move data' do
      let!(:moves) { create_list :move, 21 }
      let(:move_id) { moves.first.id }
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

      it 'returns a success code' do
        get '/api/v1/moves', headers: valid_headers
        expect(response).to be_successful
      end

      it 'returns a list of moves' do
        get '/api/v1/moves', headers: valid_headers
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end

      it 'paginates 20 results per page' do
        get '/api/v1/moves', headers: valid_headers

        expect(JSON.parse(response.body)['data'].size).to eq 20
      end

      it 'returns 1 result on the second page' do
        get '/api/v1/moves?page=2', headers: valid_headers

        expect(JSON.parse(response.body)['data'].size).to eq 1
      end

      it 'allows setting a different page size' do
        get '/api/v1/moves?per_page=15', headers: valid_headers

        expect(JSON.parse(response.body)['data'].size).to eq 15
      end

      it 'provides meta data with pagination' do
        get '/api/v1/moves', headers: valid_headers

        expect(JSON.parse(response.body)['meta']['pagination']).to include_json(meta_pagination)
      end
    end

    describe 'params' do
      let!(:move) { create :move }
      let(:move_id) { move.id }
      let(:filters) do
        {
          bar: 'bar',
          from_location_id: move.from_location_id,
          foo: 'foo'
        }
      end
      let(:move_finder) { double }

      before do
        allow(move_finder).to receive(:call).and_return(Move.all)
        allow(Moves::MoveFinder).to receive(:new).and_return(move_finder)
      end

      it 'delegates the query execution to Moves::MoveFinder with the correct filters' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: filters }
        expect(Moves::MoveFinder).to have_received(:new).with(from_location_id: move.from_location_id)
      end

      it 'returns results from Moves::MoveFinder' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: filters }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) do
        File.open("#{Rails.root}/swagger/v1/get_moves_responses.json") do |file|
          JSON.parse(file.read)
        end
      end
      let(:response_json) { JSON.parse(response.body) }

      it 'returns a valid 200 JSON response with move data' do
        get '/api/v1/moves', headers: valid_headers
        expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/200')).to be true
      end

      it 'returns a valid 415 JSON response' do
        get '/api/v1/moves', headers: invalid_headers
        expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
      end
    end
  end
end
