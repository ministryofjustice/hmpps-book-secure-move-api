# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FrameworkResponsesController do
  describe 'PATCH /framework_responses/:framework_response_id' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:framework_response) { create(:string_response) }
    let(:framework_response_id) { framework_response.id }
    let(:value) { 'No' }

    let(:framework_response_params) do
      {
        data: {
          "type": 'framework_responses',
          "attributes": {
            "value": value,
          },
        },
      }
    end

    before do
      patch "/api/v1/framework_responses/#{framework_response_id}", params: framework_response_params, headers: headers, as: :json
      framework_response.reload
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('patch_framework_response_responses.yaml') }

      context 'when response is a string' do
        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": value,
              "value_type": 'string',
              "responded": true,
            },
          })
        end
      end

      context 'when response is an array' do
        let(:framework_response) { create(:array_response) }
        let(:value) { ['Level 1', 'Level 2'] }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": value,
              "value_type": 'array',
              "responded": true,
            },
          })
        end
      end

      context 'when response is an object' do
        let(:framework_response) { create(:object_response, :details) }
        let(:value) { { option: 'No', details: 'Some details' } }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": value,
              "value_type": 'object',
              "responded": true,
            },
          })
        end
      end

      context 'when response is a collection' do
        let(:framework_response) { create(:collection_response, :details) }
        let(:value) { [{ option: 'Level 1', details: 'Some details' }, { option: 'Level 2' }] }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": value,
              "value_type": 'collection',
              "responded": true,
            },
          })
        end
      end

      context 'when incorrect keys added to collection response' do
        let(:framework_response) { create(:collection_response, :details) }
        let(:value) { [{ option: 'Level 1', detailss: 'Some details' }] }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": [{ option: 'Level 1' }],
              "value_type": 'collection',
              "responded": true,
            },
          })
        end
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with a bad request' do
        let(:framework_response_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with an invalid value' do
        let(:value) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Unprocessable entity',
               'detail' => 'Value is not included in the list' }]
          end
        end
      end

      context 'when the framework_response_id is not found' do
        let(:framework_response_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find FrameworkResponse with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
