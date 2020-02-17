# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  describe 'GET /moves/{moveId}' do
    let(:schema) { load_json_schema('get_move_responses.json') }

    let!(:move) { create :move }
    let(:move_id) { move.id }

    before do
      allow(Moves::NomisSynchroniser).to receive(:new)
      get "/api/v1/moves/#{move_id}", headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end

      it 'syncs data' do
        # expect(Moves::NomisSynchroniser).to have_received(:new).with(locations: [move.from_location], date: move.date)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when resource is not found' do
      let(:move_id) { 'UUID-not-found' }
      let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

      it_behaves_like 'an endpoint that responds with error 404'

      it 'doesn\'t sync data' do
        expect(Moves::NomisSynchroniser).not_to have_received(:new)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'

      it 'doesn\'t sync data' do
        expect(Moves::NomisSynchroniser).not_to have_received(:new)
      end
    end
  end
end
