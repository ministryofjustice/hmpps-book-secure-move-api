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

  describe 'PUT /moves' do
    let(:schema) { load_json_schema('patch_move_responses.json') }

    let!(:move) { create :move }
    let(:move_id) { move.id }

    # let(:move_attributes) { attributes_for(:move) }
    let(:move_params) do
      {
        type: 'moves',
        attributes: {
          status: 'cancelled'
        }
      }
    end

    # before do
    #   next if RSpec.current_example.metadata[:skip_before]
    #   put '/api/v1/moves', params: { data: move_params }, headers: headers, as: :json
    # end

    context 'when successful' do
      let(:move) { Move.first }

      # it_behaves_like 'an endpoint that responds with success 201'

      it 'updates the status of a move', skip_before: true do
        put '/api/v1/moves', params: { data: move_params }, headers: headers, as: :json
        expect(move.reload.status).to eq 'cancelled'
      end

      # it 'returns the correct data' do
      #   expect(response_json).to eq resource_to_json
      # end
    end

    # context 'with a bad request' do
    #   let(:data) { nil }

    #   it_behaves_like 'an endpoint that responds with error 400'
    # end

    # context 'when not authorized', with_invalid_auth_headers: true do
    #   it_behaves_like 'an endpoint that responds with error 401'
    # end

    # context 'with a reference to a missing relationship' do
    #   let(:person) { Person.new }
    #   let(:detail_404) { "Couldn't find Person without an ID" }

    #   it_behaves_like 'an endpoint that responds with error 404'
    # end

    # context 'with an invalid CONTENT_TYPE header' do
    #   let(:content_type) { 'application/xml' }

    #   it_behaves_like 'an endpoint that responds with error 415'
    # end

    # context 'with validation errors' do
    #   let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'invalid') }

    #   let(:errors_422) do
    #     [
    #       {
    #         'title' => 'Unprocessable entity',
    #         'detail' => "Date can't be blank",
    #         'source' => { 'pointer' => '/data/attributes/date' },
    #         'code' => 'blank'
    #       },
    #       {
    #         'title' => 'Unprocessable entity',
    #         'detail' => 'Status is not included in the list',
    #         'source' => { 'pointer' => '/data/attributes/status' },
    #         'code' => 'inclusion'
    #       }
    #     ]
    #   end

    #   it_behaves_like 'an endpoint that responds with error 422'
    # end
  end
end
