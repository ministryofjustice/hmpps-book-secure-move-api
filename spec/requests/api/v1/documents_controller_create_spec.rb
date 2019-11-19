# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, with_client_authentication: true do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /moves/:move_id/documents' do
    let(:schema) { load_json_schema('post_documents_responses.json') }

    let(:move) { create(:move) }
    let(:file) do
      Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec/fixtures', 'file-sample_100kB.doc'),
        'application/msword'
      )
    end
    let(:data) do
      {
        attributes: {
          description: 'A very important document',
          document_type: 'ID document',
          file: file
        }
      }
    end

    before do
      post "/api/v1/moves/#{move.id}/documents", params: { data: data }, headers: headers
    end

    it_behaves_like 'an endpoint that responds with success 201'

    it 'adds a document to the move' do
      expect(move.documents.count).to eq(1)
    end

    it 'attaches a file to the document' do
      expect(move.documents.last.file).to be_attached
    end
  end
end
