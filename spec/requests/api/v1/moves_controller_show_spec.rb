# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  path '/moves/{moveId}' do
    get 'Returns the details of a move' do
      tags 'Moves'
      produces 'application/json'

      parameter name: :Authorization,
                in: :header,
                schema: {
                  type: 'string',
                  default: 'Bearer <your-client-token>'
                },
                required: true,
                description: <<~DESCRIPTION
                  This is "Bearer ", followed by your OAuth 2 Client token.
                  If you're testing interactively in the web UI, you can ignore this field
                DESCRIPTION

      parameter name: 'Content-Type',
                in: 'header',
                description: 'Accepted request content type',
                schema: {
                  type: 'string',
                  default: 'application/vnd.api+json'
                },
                required: true

      parameter name: :moveId,
                in: :path,
                description: 'The ID of the move',
                schema: {
                  type: :string
                },
                format: 'uuid',
                example: '00525ecb-7316-492a-aae2-f69334b2a155',
                required: true

      response '200', 'success' do
        let!(:move) { create :move }
        let(:moveId) { move.id }

        after do |example|
          example.metadata[:response][:examples] = {
            'application/json' => JSON.parse(response.body, symbolize_names: true)
          }
        end

        run_test!
      end
    end
  end

  describe 'GET /api/v1/moves/{moveId}' do
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
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when resource is not found' do
      let(:move_id) { 'UUID-not-found' }

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
