# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DocumentsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { 'multipart/form-data' }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json',
      'Authorization' => "Bearer #{access_token}",
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
           { url: a_string_starting_with('http://www.example.com/rails/active_storage/disk'), # "http://www.example.com/rails/active_storage/disk/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdDRG9JYTJWNVNTSWhlV0oxYXprNFkyUmtZV1UxTm1SNWFXWjZaelV3Wm01NU4zRXpiZ1k2QmtWVU9oQmthWE53YjNOcGRHbHZia2tpV1dGMGRHRmphRzFsYm5RN0lHWnBiR1Z1WVcxbFBTSm1hV3hsTFhOaGJYQnNaVjh4TURCclFpNWtiMk1pT3lCbWFXeGxibUZ0WlNvOVZWUkdMVGduSjJacGJHVXRjMkZ0Y0d4bFh6RXdNR3RDTG1Sdll3WTdCbFE2RVdOdmJuUmxiblJmZEhsd1pTSVhZWEJ3YkdsallYUnBiMjR2YlhOM2IzSmsiLCJleHAiOiIyMDIwLTA2LTI1VDEzOjE3OjIzWiIsInB1ciI6ImJsb2Jfa2V5In19--2b4628c3ac424585800cf86fbd36496820cbd54e/file-sample_100kB.doc?content_type=application%2Fmsword&disposition=attachment%3B+filename%3D%22file-sample_100kB.doc%22%3B+filename%2A%3DUTF-8%27%27file-sample_100kB.doc",
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
