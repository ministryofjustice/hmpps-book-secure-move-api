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
        pending 'content-type header enforcement not implemented yet'
        expect(response).not_to be_successful
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

    describe 'filters' do
      let!(:move) { create :move }
      let(:move_id) { move.id }

      it 'returns moves selected by from location' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: { from_location_id: move.from_location_id } }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end

      it 'does not return moves filtered out by from location' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: { from_location_id: Random.uuid } }
        expect(JSON.parse(response.body)).not_to include_json(data: [{ id: move_id }])
      end

      it 'returns moves selected by to_location_type' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: { location_type: move.to_location.location_type } }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end

      it 'does not return moves filtered out by to_location_type' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: { location_type: 'hospital' } }
        expect(JSON.parse(response.body)).not_to include_json(data: [{ id: move_id }])
      end

      it 'returns moves selected by date range' do
        filters = { date_from: Date.today.to_s, date_to: 5.days.from_now.to_date.to_s }
        get '/api/v1/moves', headers: valid_headers, params: { filter: filters }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end

      it 'does not return moves filtered out by date range in past' do
        filters = { date_from: 5.days.ago.to_date.to_s, date_to: 2.days.ago.to_date.to_s }
        get '/api/v1/moves', headers: valid_headers, params: { filter: filters }
        expect(JSON.parse(response.body)).not_to include_json(data: [{ id: move_id }])
      end

      it 'does not return moves filtered out by date range in future' do
        filters = { date_from: 2.days.from_now.to_date.to_s, date_to: 5.days.from_now.to_date.to_s }
        get '/api/v1/moves', headers: valid_headers, params: { filter: filters }
        expect(JSON.parse(response.body)).not_to include_json(data: [{ id: move_id }])
      end

      it 'returns moves selected by status' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: { status: move.status } }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end

      it 'does not return moves filtered out by status' do
        get '/api/v1/moves', headers: valid_headers, params: { filter: { status: 'not_a_status' } }
        expect(JSON.parse(response.body)).not_to include_json(data: [{ id: move_id }])
      end
    end
  end
end
