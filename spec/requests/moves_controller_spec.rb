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
      let(:from_location) { Location.create!(label: 'Pentonville', location_type: 'prison') }
      let(:to_location) { Location.create!(label: 'Guildford Crown Court', location_type: 'court') }
      let(:person) { Person.create! }
      let(:valid_attributes) do
        {
          from_location: from_location,
          to_location: to_location,
          person: person,
          date: Date.today,
          time_due: Time.now,
          move_type: 'foo',
          status: 'draft'
        }
      end
      let!(:move) { Move.create!(valid_attributes) }
      let(:move_id) { move.id }

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
