# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DocumentsController do
  let(:content_type) { 'multipart/form-data' }
  let(:response_json) { JSON.parse(response.body) }

  # rubocop thinks this context is empty IMHO because it doesn't understand rswag
  #rubocop:disable RSpec/EmptyExampleGroup
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

          schema "$ref": '#/definitions/post_document_responses/201'

          run_test! do |_example|
            expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))

            expect(JSON.parse(response.body)).to eq resource_to_json
          end
        end
      end
    end
  end
  #rubocop:enable RSpec/EmptyExampleGroup

  describe 'POST /moves/:move_id/documents' do
    let(:schema) { load_json_schema('post_documents_responses.json') }
    let(:move) { create(:move) }
    let(:access_token) { create(:access_token).token }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

    before do
      post "/api/v1/moves/#{move.id}/documents", params: { data: data }, headers: headers
    end

    context 'when successful' do
      let(:file) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec/fixtures/file-sample_100kB.doc'),
          'application/msword',
        )
      end
      let(:data) do
        {
          attributes: {
            file: file,
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'adds a document to the move' do
        expect(move.documents.count).to eq(1)
      end

      it 'attaches a file to the document' do
        expect(move.documents.last.file).to be_attached
      end

      it 'adds the right file to the document' do
        expect(move.documents.last.file.filename).to eq 'file-sample_100kB.doc'
      end
    end

    context 'with a bad request' do
      let(:data) do
        {
          attributes: {
            file: nil,
          },
        }
      end
      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "File can't be blank",
            'source' => { 'pointer' => '/data/attributes/file' },
            'code' => "can't be blank",
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:data) { {} }
      let(:detail_401) { 'Token expired or invalid' }
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }

      it_behaves_like 'an endpoint that responds with error 401'
    end
  end
end
