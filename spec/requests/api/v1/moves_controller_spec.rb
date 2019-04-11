# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  let(:valid_headers) { { 'CONTENT_TYPE': 'application/vnd.api+json' } }

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

      it 'fails if I set the wrong `content-type` header' do
        get '/api/v1/moves', headers: { 'CONTENT_TYPE': 'application/xml' }
        expect(response.code).to eql '415'
      end
    end

    context 'with move data' do
      let!(:move) { create :move }
      let(:move_id) { move.id }

      it 'returns a success code' do
        get '/api/v1/moves', headers: valid_headers
        expect(response).to be_successful
      end

      it 'returns a list of moves' do
        get '/api/v1/moves', headers: valid_headers
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
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
        allow(move_finder).to receive(:call).and_return([move])
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
  end
end
