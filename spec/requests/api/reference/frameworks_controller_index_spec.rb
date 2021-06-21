# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::FrameworksController do
  let(:headers) { { 'Authorization' => 'Bearer spoofed-token' } }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/reference/frameworks' do
    let(:schema) { load_yaml_schema('get_frameworks_responses.yaml') }

    let!(:framework1) { create(:framework, version: '1.0.0') }
    let!(:framework2) { create(:framework, version: '1.0.1') }

    let(:data) do
      [
        {
          type: 'frameworks',
          attributes: {
            name: framework2.name,
            version: framework2.version,
          },
          relationships: {},
        },
        {
          type: 'frameworks',
          attributes: {
            name: framework1.name,
            version: framework1.version,
          },
          relationships: {},
        },
      ]
    end

    before do
      get '/api/v1/reference/frameworks', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end
  end
end
