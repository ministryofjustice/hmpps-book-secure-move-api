# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { described_class::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: document))
  end

  let(:detail_404) { "Couldn't find Document with 'id'=UUID-not-found" }

  describe 'DELETE /moves/{move_id}/documents/{document_id}' do
    let(:schema) { load_json_schema('delete_document_responses.json') }

    let!(:move) { create :move }
    let!(:document) { create :document, move: move }
    let(:move_id) { move.id }
    let(:document_id) { document.id }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      delete "/api/v1/moves/#{move_id}/documents/#{document_id}", headers: headers
    end

    context 'when successful' do
      it 'returns a success code' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a valid 200 JSON response', with_json_schema: true do
        expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
      end

      it 'forces the content type to ApiController::CONTENT_TYPE' do
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
      end

      it 'deletes the document from the move', skip_before: true do
        expect { delete "/api/v1/moves/#{move_id}/documents/#{document_id}", headers: headers }
          .to change { move.documents.count }.by(-1)
      end

      it 'does not delete the document', skip_before: true do
        expect { delete "/api/v1/moves/#{move_id}/documents/#{document_id}", headers: headers }
          .not_to change(Document, :count)
      end

      it 'does not delete the move' do
        expect { delete "/api/v1/moves/#{move_id}/documents/#{document_id}", headers: headers }
          .not_to change(Move, :count)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when resource is not found' do
      let(:document_id) { 'UUID-not-found' }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
