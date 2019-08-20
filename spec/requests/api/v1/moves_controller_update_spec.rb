# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move.reload, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'PATCH /moves' do
    let(:schema) { load_json_schema('patch_move_responses.json') }

    let!(:move) { create :move }
    let(:move_id) { move.id }

    let(:move_params) do
      {
        type: 'moves',
        attributes: {
          status: 'cancelled',
          additional_information: 'some more info'
        }
      }
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the status of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(move.reload.status).to eq 'cancelled'
      end

      it 'updates the additional_information of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(move.reload.additional_information).to eq 'some more info'
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'with a read-only attribute' do
      let!(:move) { create :move }

      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'cancelled',
            reference: 'new reference'
          }
        }
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the status of a move', skip_before: true do
        patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
        expect(move.reload.status).to eq 'cancelled'
      end

      it 'does NOT update the reference of a move', skip_before: true do
        expect { patch("/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json) }.not_to(
          change { move.reload.reference }
        )
      end
    end

    context 'with a bad request' do
      let(:move_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with a missing move' do
      let(:move_id) { 'null' }
      let(:detail_404) { "Couldn't find Move with 'id'=null" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'invalid'
          }
        }
      end

      let(:errors_422) do
        [
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
end
