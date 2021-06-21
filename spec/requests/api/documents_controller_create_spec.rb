# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DocumentsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:headers) do
    {
      'CONTENT_TYPE': 'multipart/form-data',
      'Accept': 'application/vnd.api+json',
      'Authorization' => 'Bearer spoofed-token',
    }
  end

  describe 'POST /people' do
    let(:file) { fixture_file_upload('file-sample_100kB.doc', 'application/msword') }
    let(:document_params) do
      {
        data: {
          attributes: {
            file: file,
          },
        },
      }
    end

    let(:expected_data) do
      {
        type: 'documents',
        attributes:
           { url: a_string_starting_with('http://www.example.com/rails/active_storage/disk'),
             filename: 'file-sample_100kB.doc',
             filesize: 100_352,
             content_type: 'application/msword' },
      }
    end

    it 'returns the correct data' do
      post '/api/documents', params: document_params, headers: headers

      expected_document_id = Document.last.id

      expect(response.status).to eq(201)
      expect(response_json).to include_json(data: expected_data.merge(id: expected_document_id))
    end

    context 'with a bad request' do
      before { post '/api/documents', params: {}, headers: headers }

      it_behaves_like 'an endpoint that responds with error 400'
    end
  end
end
