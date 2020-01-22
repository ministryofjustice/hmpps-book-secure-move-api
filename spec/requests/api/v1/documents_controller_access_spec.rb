require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, with_client_authentication: true do
  let!(:application) { Doorkeeper::Application.create(name: 'test', owner: pentonville_supplier) }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:response_json) { JSON.parse(response.body) }

  let(:pentonville_supplier) { create :supplier, name: 'pvi supplier' }
  let(:birmingham_supplier) { create :supplier, name: 'hmp supplier' }
  let!(:pentonville) { create :location, suppliers: [pentonville_supplier] }
  let!(:birmingham) do
    create :location,
           key: 'hmp_birmingham', title: 'HMP Birmingham', nomis_agency_id: 'BMI', suppliers: [birmingham_supplier]
  end

  describe 'POST /moves/:move_id/documents' do
    let(:schema) { load_json_schema('post_documents_responses.json') }
    let(:content_type) { 'multipart/form-data' }
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

    before do
      post "/api/v1/moves/#{move.id}/documents", params: { data: data }, headers: headers
    end

    context 'when successful' do
      let(:move) { create :move, from_location: pentonville }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'attaches a file to the document' do
        expect(move.documents.last.file).to be_attached
      end
    end

    context 'when supplier doesn\'t have rights to write the resource' do
      let(:move) { create :move, from_location: birmingham }
      let(:detail_404) { "Couldn't find Move with 'id'=#{move.id} [WHERE (from_location_id IN ('#{pentonville.id}'))]" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end

  describe 'DELETE /moves/{moveId}/documents/{documentId}' do
    let(:schema) { load_json_schema('delete_document_responses.json') }
    let(:content_type) { described_class::CONTENT_TYPE }

    let!(:document) { create :document, move: move }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      delete "/api/v1/moves/#{move.id}/documents/#{document.id}", headers: headers
    end

    context 'when successful' do
      let(:move) { create :move, from_location: pentonville }

      it 'returns a valid 200 JSON response', with_json_schema: true do
        expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
      end

      it 'deletes the document', skip_before: true do
        expect { delete "/api/v1/moves/#{move.id}/documents/#{document.id}", headers: headers }
          .to change(Document, :count).by(-1)
      end
    end

    context 'when supplier doesn\'t have rights to write the resource' do
      let(:move) { create :move, from_location: birmingham }
      let(:detail_404) { "Couldn't find Move with 'id'=#{move.id} [WHERE (from_location_id IN ('#{pentonville.id}'))]" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
