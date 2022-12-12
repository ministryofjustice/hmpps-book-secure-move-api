# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  subject { create(:event_move_collection_by_escort) }

  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('get_event_responses.yaml', version: 'v2') }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:resource_to_json) do
    JSON.parse(GenericEventSerializer.new(subject).serializable_hash.to_json)
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
      'X-Current-User' => 'TEST_USER',
    }
  end

  describe 'GET /events/:id' do
    it 'returns serialized data' do
      do_get
      expect(response_json).to eq resource_to_json
    end

    it_behaves_like 'an endpoint that responds with success 200' do
      before { do_get }
    end
  end

  def do_get
    get "/api/events/#{subject.id}", headers: headers, as: :json
  end
end
