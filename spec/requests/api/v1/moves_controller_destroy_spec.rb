# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::SUPPORTED_RELATIONSHIPS))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'DELETE /moves/{move_id}' do
    let(:schema) { load_yaml_schema('delete_move_responses.yaml') }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

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
        expect { delete "/api/v1/moves/#{move_id}", headers: headers }
            .not_to change(Person, :count)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:detail_401) { 'Token expired or invalid' }
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }

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
