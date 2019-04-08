# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovesController do
  let(:valid_headers) { { 'CONTENT_TYPE': 'application/vnd.api+json' } }

  describe 'GET /moves' do
    context 'when there is no data' do
      it 'returns a success code' do
        get '/moves', headers: valid_headers
        expect(response).to be_successful
      end

      it 'returns an empty list' do
        get '/moves', headers: valid_headers
        expect(JSON.parse(response.body)).to include_json(data: [])
      end

      it 'fails if I set the wrong `content-type` header' do
        get '/moves', headers: { 'CONTENT_TYPE': 'application/xml' }
        pending 'content-type header enforcement not implemented yet'
        expect(response).not_to be_successful
      end
    end

    context 'with move data' do
      let(:move_id) { Random.uuid }
      let(:moves) { [Move.new(id: move_id)] }

      before do
        allow(Move).to receive(:all).and_return(moves)
      end

      it 'returns a success code' do
        get '/moves', headers: valid_headers
        expect(response).to be_successful
      end

      it 'returns a list of moves' do
        get '/moves', headers: valid_headers
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end
    end
  end
end
