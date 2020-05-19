# frozen_string_literal: true

# TODO move Swagger to hand_coded_paths.yaml
# TODO move to controller spec

require 'swagger_helper'

RSpec.describe Api::V1::AllocationsController, :with_client_authentication, :rswag, type: :request do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:allocation) { create :allocation }
  let(:allocation_id) { allocation.id }

  path '/allocations/{allocation_id}' do
    get 'Returns the details of an allocation' do
      tags 'Allocations'
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

      parameter name: :allocation_id,
                in: :path,
                description: 'The ID of the allocation',
                schema: {
                  type: :string,
                },
                format: 'uuid',
                example: '00525ecb-7316-492a-aae2-f69334b2a155',
                required: true

      response '200', 'success' do
        let(:resource_to_json) do
          JSON.parse(ActionController::Base.render(json: allocation, include: AllocationSerializer::SUPPORTED_RELATIONSHIPS))
        end

        schema '$ref' => 'get_allocation_responses.yaml#/200'

        run_test! do |_example|
          expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))

          expect(JSON.parse(response.body)).to eq resource_to_json
        end
      end

      response '401', 'unauthorised' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('bogus-credentials')}" }

        it_behaves_like 'a swagger 401 error'
      end

      response '404', 'not found' do
        let(:allocation_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find Allocation with 'id'=#{allocation_id}" }

        it_behaves_like 'a swagger 404 error'
      end

      response '415', 'invalid content type' do
        let(:"Content-Type") { 'application/xml' }
        it_behaves_like 'a swagger 415 error'
      end
    end
  end
end
