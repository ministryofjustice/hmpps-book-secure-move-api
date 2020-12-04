# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::Reference::PrisonTransferReasonsController, :rswag, :with_client_authentication do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let!(:reason) { create :prison_transfer_reason }
  let!(:reasons) { [reason] }

  path '/reference/prison_transfer_reasons' do
    let(:"Content-Type") { content_type }
    get 'Returns all prison transfer reasons' do
      tags 'PrisonTransferReasons'
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

      parameter name: :'Content-Type',
                in: :header,
                description: 'Accepted request content type',
                schema: {
                  type: 'string',
                  default: 'application/vnd.api+json',
                },
                required: true

      response '200', 'success' do
        let(:resource_to_json) do
          JSON.parse(PrisonTransferReasonSerializer.new(reasons).serializable_hash.to_json)
        end

        schema '$ref' => 'get_prison_transfer_reasons_responses.yaml#/200'

        run_test! do |_example|
          expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))

          expect(JSON.parse(response.body)).to eq resource_to_json
        end
      end

      response '401', 'unauthorised' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('bogus-credentials')}" }

        it_behaves_like 'a swagger 401 error'
      end

      response '415', 'invalid content type' do
        let(:"Content-Type") { 'application/xml' }

        it_behaves_like 'a swagger 415 error'
      end
    end
  end
end
