# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { 'multipart/form-data' }
  let(:response_json) { JSON.parse(response.body) }

  before do
    post "/api/v1/moves/#{move.id}/documents", params: { data: data }, headers: headers
  end

  describe 'POST /moves/:move_id/documents' do
    let(:schema) { load_json_schema('post_documents_responses.json') }
    let(:move) { create(:move) }

    context 'when successful' do
      let(:file) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec/fixtures/file-sample_100kB.doc'),
          'application/msword'
        )
      end
      let(:data) do
        {
          attributes: {
            file: file
          }
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
            file: nil
          }
        }
      end
      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "File can't be blank",
            'source' => { 'pointer' => '/data/attributes/file' },
            'code' => "can't be blank"
          }
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:data) { {} }
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end
  end
end
