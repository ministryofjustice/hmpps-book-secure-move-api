# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DocumentsController do
  let(:content_type) { 'multipart/form-data' }
  let(:response_json) { JSON.parse(response.body) }

  context 'with swagger generation', :with_client_authentication, :rswag do
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }

    path '/documents' do
      post 'Creates a document' do
        tags 'Documents'
        consumes 'multipart/form-data'
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
                    default: 'multipart/form-data',
                  },
                  required: true

        parameter name: :'data[attributes][file]',
                  description: 'The file being uploaded',
                  in: :formData,
                  attributes: {
                    schema: {
                      type: :object,
                      properties: {
                        file: { type: :binary },
                      },
                    },
                  }

        response '201', 'created' do
          let(:resource_to_json) do
            JSON.parse(ActionController::Base.render(json: Document.last))
          end
          let(:'data[attributes][file]') do
            Rack::Test::UploadedFile.new(
              Rails.root.join('spec/fixtures/file-sample_100kB.doc'),
              'application/msword',
            )
          end

          schema '$ref' => 'post_documents_responses.yaml#/201'

          run_test! do |_example|
            expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))

            expect(JSON.parse(response.body)).to eq resource_to_json
          end
        end
      end
    end
  end
end
