# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FrameworkResponsesController do
  describe 'PATCH /framework_responses/:framework_response_id' do
    include_context 'with supplier with spoofed access token'

    let(:schema) { load_yaml_schema('patch_framework_response_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:framework_response) { create(:string_response) }
    let!(:flag) { create(:framework_flag, framework_question: framework_response.framework_question, question_value: 'No') }
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
              "value_type": 'object::followup_comment',
              "responded": true,
            },
          })
        end
      end

      context 'when response is a details collection' do
        let(:framework_response) { create(:collection_response, :details) }
        let(:value) { [{ option: 'Level 1', details: 'Some details' }, { option: 'Level 2' }] }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": value,
              "value_type": 'collection::followup_comment',
              "responded": true,
            },
          })
        end
      end

      context 'when response is a multiple item collection' do
        let(:framework_response) { create(:collection_response, :multiple_items, framework_question: question, value: nil) }
        let(:question1) { create(:framework_question) }
        let(:question2) { create(:framework_question, :checkbox) }
        let(:question3) { create(:framework_question, :checkbox, followup_comment: true) }
        let(:question4) { create(:framework_question, followup_comment: true) }
        let(:question) { create(:framework_question, :add_multiple_items, dependents: [question1, question2, question3, question4]) }
        let(:value) do
          [
            { item: 1, responses: [{ value: 'No', framework_question_id: question1.id }] },
            { item: 2, responses: [{ value: ['Level 2'], framework_question_id: question2.id }] },
            { item: 3, responses: [{ value: [{ option: 'Level 1', details: 'some detail' }], framework_question_id: question3.id }] },
            { item: 4, responses: [{ value: { option: 'No', details: 'some detail' }, framework_question_id: question4.id }] },
          ]
        end

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": value,
              "value_type": 'collection::add_multiple_items',
              "responded": true,
            },
          })
        end
      end

      context 'when incorrect keys added to details collection response' do
        let(:framework_response) { create(:collection_response, :details) }
        let(:value) { [{ option: 'Level 1', detailss: 'Some details' }] }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": [{ option: 'Level 1' }],
              "value_type": 'collection::followup_comment',
              "responded": true,
            },
          })
        end
      end

      context 'when incorrect keys added to multiple items collection response' do
        let(:framework_response) { create(:collection_response, :multiple_items) }
        let(:framework_question) { framework_response.framework_question.dependents.first }

        let(:value) do
          [
            { items: 1, responses: [{ value: ['Level 1'], framework_question_id: framework_question.id }] },
            { item: 2, responses: [{ value: ['Level 2'], framework_question_id: framework_question.id }] },
          ]
        end

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": [{ item: 2, responses: [{ value: ['Level 2'], framework_question_id: framework_question.id }] }],
              "value_type": 'collection::add_multiple_items',
              "responded": true,
            },
          })
        end
      end

      context 'when incorrect keys added to object response' do
        let(:framework_response) { create(:object_response, :details) }
        let(:value) { { option: 'Yes', detailss: 'Some details' } }

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "attributes": {
              "value": { option: 'Yes' },
              "value_type": 'object::followup_comment',
              "responded": true,
            },
          })
        end
      end

      context 'with flags' do
        it 'attaches a flag and returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": framework_response_id,
            "type": 'framework_responses',
            "relationships": {
              "flags": {
                "data": [
                  {
                    id: flag.id,
                    type: 'framework_flags',
                  },
                ],
              },
            },
          })
        end
      end
    end

    context 'when unsuccessful' do
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

      context 'with incorrect value type' do
        let(:value) { %w[foo-bar] }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [
              {
                'title' => 'Invalid Value type',
                'detail' => 'Value: ["foo-bar"] is incorrect type',
                'source' => { pointer: '/data/attributes/value' },
              },
            ]
          end
        end
      end

      context 'with a nested invalid value' do
        let(:framework_response) { create(:collection_response, :multiple_items) }
        let(:framework_question) { framework_response.framework_question.dependents.first }

        let(:value) do
          [
            { item: 1, responses: [{ value: ['Level 1'], framework_question_id: framework_question.id }] },
            { item: 2, responses: [{ value: ['Level 3'], framework_question_id: framework_question.id }] },
            { item: 3, responses: [{ value: ['Level 2'], framework_question_id: framework_question.id }] },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Unprocessable entity',
               'detail' => 'Items[1].responses[0].value level 3 are not valid options' }]
          end
        end
      end

      context 'with a nested incorrect value type' do
        let(:framework_response) { create(:collection_response, :multiple_items) }
        let(:framework_question) { framework_response.framework_question.dependents.first }

        let(:value) do
          [
            { item: 1, responses: [{ value: ['Level 1'], framework_question_id: framework_question.id }] },
            { item: 2, responses: [{ value: 'Level 2', framework_question_id: framework_question.id }] },
            { item: 3, responses: [{ value: ['Level 2'], framework_question_id: framework_question.id }] },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [
              {
                'title' => 'Invalid Value type',
                'detail' => 'Value: Level 2 is incorrect type',
                'source' => { pointer: '/data/attributes/value' },
              },
            ]
          end
        end
      end

      context 'when person_escort_record confirmed' do
        let(:person_escort_record) { create(:person_escort_record, :confirmed) }
        let(:framework_response) { create(:string_response, assessmentable: person_escort_record) }
        let(:detail_403) do
          "Can't update framework_responses because assessment is confirmed"
        end

        it_behaves_like 'an endpoint that responds with error 403'
      end

      context 'when the framework_response_id is not found' do
        let(:framework_response_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find FrameworkResponse with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
