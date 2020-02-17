# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::MovesController, :with_client_authentication, :rswag, type: :request do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:move) { create :move }
  let(:move_id) { move.id }

  path '/moves/{move_id}' do
    get 'Returns the details of a move' do
      tags 'Moves'
      produces 'application/vnd.api+json'

      parameter name: :Authorization,
                in: :header,
                schema: {
                  type: 'string',
                  default: 'Bearer <your-client-token>',
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
                  default: 'application/vnd.api+json',
                },
                required: true

      parameter name: :move_id,
                in: :path,
                description: 'The ID of the move',
                schema: {
                  type: :string,
                },
                format: 'uuid',
                example: '00525ecb-7316-492a-aae2-f69334b2a155',
                required: true

      response '200', 'success' do
        let(:resource_to_json) do
          JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
        end

        schema "$ref": '#/definitions/get_move_responses/200'

        run_test! do |_example|
          expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))

          expect(JSON.parse(response.body)).to eq resource_to_json

          # TODO: this was commented out in the original test, and fails when included
          # expect(Moves::NomisSynchroniser).to(
          #     have_received(:new).with(locations: [move.from_location], date: move.date)
          #   )
        end
      end

      response '401', 'unauthorised' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('bogus-credentials')}" }

        it_behaves_like 'a swagger 401 error'
        it_behaves_like 'it does not trigger NomisSynchroniser'
      end

      response '404', 'not found' do
        let(:move_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find Move with 'id'=#{move_id}" }

        it_behaves_like 'a swagger 404 error'
        it_behaves_like 'it does not trigger NomisSynchroniser'
      end

      response '415', 'invalid content type' do
        let(:"Content-Type") { 'application/xml' }
        it_behaves_like 'a swagger 415 error'
        it_behaves_like 'it does not trigger NomisSynchroniser'
      end
    end
  end
end
