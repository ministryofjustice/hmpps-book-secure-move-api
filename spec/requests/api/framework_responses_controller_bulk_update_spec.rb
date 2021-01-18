# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FrameworkResponsesController do
  describe 'PATCH /person_escort_records/:per_id/framework_responses' do
    include_context 'with supplier with spoofed access token'

    subject(:bulk_update_framework_responses) do
      Timecop.freeze(recorded_timestamp)
      patch "/api/person_escort_records/#{per_id}/framework_responses", params: bulk_per_params, headers: headers, as: :json
      Timecop.return
    end

    let(:schema) { load_yaml_schema('patch_framework_response_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:recorded_timestamp) { Time.zone.parse('2020-10-07 01:02:03').iso8601 }
    let(:person_escort_record) { create(:person_escort_record, :in_progress) }
    let(:per_id) { person_escort_record.id }

    let(:framework_response) { create(:string_response, assessmentable: person_escort_record, value: 'No') }
    let(:other_framework_response) { create(:string_response, assessmentable: person_escort_record, value: 'Yes') }
    let(:framework_response_id) { framework_response.id }
    let(:other_framework_response_id) { other_framework_response.id }

    let!(:flag) { create(:framework_flag, framework_question: framework_response.framework_question, question_value: 'Yes') }
    let!(:other_flag) { create(:framework_flag, framework_question: other_framework_response.framework_question, question_value: 'No') }

    let(:value) { 'Yes' }
    let(:other_value) { 'No' }

    let(:bulk_per_params) do
      {
        data: [
          {
            id: framework_response_id,
            type: 'framework_responses',
            attributes: {
              value: value,
            },
          },
          {
            id: other_framework_response_id,
            type: 'framework_responses',
            attributes: {
              value: other_value,
            },
          },
        ],
      }
    end

    context 'when successful' do
      before { bulk_update_framework_responses }

      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates PER status' do
        expect(person_escort_record.reload.status).to eq('completed')
      end

      it 'attaches flags to the responses' do
        expect(framework_response.framework_flags).to contain_exactly(flag)
        expect(other_framework_response.framework_flags).to contain_exactly(other_flag)
      end

      it 'returns the responded by value' do
        expect(framework_response.reload.responded_by).to eq('TEST_USER')
      end

      it 'returns the responded at timestamp' do
        expect(framework_response.reload.responded_at).to eq(recorded_timestamp)
      end

      context 'when responses are combined' do
        let(:string_response) { create(:string_response, assessmentable: person_escort_record, value: 'No') }
        let(:array_response) { create(:array_response, assessmentable: person_escort_record) }
        let(:object_response) { create(:object_response, :details, assessmentable: person_escort_record) }
        let(:details_response) { create(:collection_response, :details, assessmentable: person_escort_record) }
        let(:multiple_items_response) { create(:collection_response, :multiple_items, framework_question: multiple_question, value: nil, assessmentable: person_escort_record) }

        let(:question1) { create(:framework_question) }
        let(:question2) { create(:framework_question, :checkbox) }
        let(:multiple_question) { create(:framework_question, :add_multiple_items, dependents: [question1, question2]) }

        let(:array_value) { ['Level 1', 'Level 2'] }
        let(:object_value) { { 'option' => 'No', 'details' => 'Some details' } }
        let(:details_value) { [{ 'option' => 'Level 1', 'details' => 'Some details' }, { 'option' => 'Level 2', 'details' => nil }] }
        let(:multiple_items_value) do
          [
            { 'item' => 1, 'responses' => [{ 'value' => 'No', 'framework_question_id' => question1.id }] },
            { 'item' => 2, 'responses' => [{ 'value' => ['Level 2'], 'framework_question_id' => question2.id }] },
          ]
        end

        let(:bulk_per_params) do
          {
            data: [
              {
                id: string_response.id,
                type: 'framework_responses',
                attributes: {
                  value: value,
                },
              },
              {
                id: array_response.id,
                type: 'framework_responses',
                attributes: {
                  value: array_value,
                },
              },
              {
                id: object_response.id,
                type: 'framework_responses',
                attributes: {
                  value: object_value,
                },
              },
              {
                id: details_response.id,
                type: 'framework_responses',
                attributes: {
                  value: details_value,
                },
              },
              {
                id: multiple_items_response.id,
                type: 'framework_responses',
                attributes: {
                  value: multiple_items_value,
                },
              },
            ],
          }
        end

        it 'updates all response values' do
          {
            string_response => value,
            array_response => array_value,
            object_response => object_value,
            details_response => details_value,
            multiple_items_response => multiple_items_value,
          }.each do |response, expected_value|
            expect(response.reload.value).to eq(expected_value)
          end
        end
      end
    end

    context 'when unsuccessful' do
      before { bulk_update_framework_responses }

      context 'with a bad request' do
        let(:bulk_per_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'when the person_escort_record_id is not found' do
        let(:per_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find PersonEscortRecord with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with invalid values' do
        let(:value) { 'foo-bar' }
        let(:other_value) { 'bar-baz' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [
              {
                'id' => framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Value is not included in the list',
              },
              {
                'id' => other_framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Value is not included in the list',
              },
            ]
          end
        end
      end

      context 'with incorrect value type' do
        let(:value) { %w[foo-bar] }
        let(:other_value) { %w[bar-baz] }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [
              {
                'id' => framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Value: ["foo-bar"] is incorrect type',
                'source' => { pointer: '/data/attributes/value' },
              },
              {
                'id' => other_framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Value: ["bar-baz"] is incorrect type',
                'source' => { pointer: '/data/attributes/value' },
              },
            ]
          end
        end
      end

      context 'with a nested invalid value' do
        let(:framework_response) { create(:collection_response, :multiple_items, assessmentable: person_escort_record) }
        let(:framework_question) { framework_response.framework_question.dependents.first }
        let(:other_framework_response) { create(:collection_response, :multiple_items, assessmentable: person_escort_record) }
        let(:other_framework_question) { other_framework_response.framework_question.dependents.first }

        let(:value) do
          [
            { item: 1, responses: [{ value: ['Level 1'], framework_question_id: framework_question.id }] },
            { item: 2, responses: [{ value: ['Level 3'], framework_question_id: framework_question.id }] },
            { item: 3, responses: [{ value: ['Level 2'], framework_question_id: framework_question.id }] },
          ]
        end
        let(:other_value) do
          [
            { item: 1, responses: [{ value: ['Level 1'], framework_question_id: other_framework_question.id }] },
            { item: 2, responses: [{ value: ['Level 3'], framework_question_id: other_framework_question.id }] },
            { item: 3, responses: [{ value: ['Level 2'], framework_question_id: other_framework_question.id }] },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [
              {
                'id' => framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Items[1] responses[0] value Level 3 are not valid options',
              },
              {
                'id' => other_framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Items[1] responses[0] value Level 3 are not valid options',
              },
            ]
          end
        end
      end

      context 'with a nested incorrect value type' do
        let(:framework_response) { create(:collection_response, :multiple_items, assessmentable: person_escort_record) }
        let(:framework_question) { framework_response.framework_question.dependents.first }
        let(:other_framework_response) { create(:collection_response, :multiple_items, assessmentable: person_escort_record) }
        let(:other_framework_question) { other_framework_response.framework_question.dependents.first }

        let(:value) do
          [
            { item: 1, responses: [{ value: ['Level 1'], framework_question_id: framework_question.id }] },
            { item: 2, responses: [{ value: 'Level 2', framework_question_id: framework_question.id }] },
            { item: 3, responses: [{ value: ['Level 2'], framework_question_id: framework_question.id }] },
          ]
        end
        let(:other_value) do
          [
            { item: 1, responses: [{ value: ['Level 1'], framework_question_id: other_framework_question.id }] },
            { item: 2, responses: [{ value: 'Level 2', framework_question_id: other_framework_question.id }] },
            { item: 3, responses: [{ value: ['Level 2'], framework_question_id: other_framework_question.id }] },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [
              {
                'id' => framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Value: Level 2 is incorrect type',
                'source' => { pointer: '/data/attributes/value' },
              },
              {
                'id' => other_framework_response_id,
                'title' => 'Invalid value',
                'detail' => 'Value: Level 2 is incorrect type',
                'source' => { pointer: '/data/attributes/value' },
              },
            ]
          end
        end
      end

      context 'when person_escort_record confirmed' do
        let(:person_escort_record) { create(:person_escort_record, :confirmed) }
        let(:detail_403) { "Can't update framework_responses because assessment is confirmed" }

        it_behaves_like 'an endpoint that responds with error 403'
      end

      context 'when the framework_response_id is not found' do
        let(:framework_response_id) { 'foo' }
        let(:other_framework_response_id) { 'bar' }
        let(:detail_404) { "Couldn't find FrameworkResponse with 'id'=[\"foo\", \"bar\"]" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end

  describe 'PATCH /youth_risk_assessments/:youth_risk_assessment_id/framework_responses' do
    include_context 'with supplier with spoofed access token'

    subject(:bulk_update_framework_responses) do
      patch "/api/youth_risk_assessments/#{youth_risk_assessment_id}/framework_responses", params: bulk_youth_risk_assessment_params, headers: headers, as: :json
    end

    let(:schema) { load_yaml_schema('patch_framework_response_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:youth_risk_assessment) { create(:youth_risk_assessment, :in_progress) }
    let(:youth_risk_assessment_id) { youth_risk_assessment.id }

    let(:framework_response) { create(:string_response, assessmentable: youth_risk_assessment, value: 'No') }
    let(:other_framework_response) { create(:string_response, assessmentable: youth_risk_assessment, value: 'Yes') }
    let(:framework_response_id) { framework_response.id }
    let(:other_framework_response_id) { other_framework_response.id }

    let!(:flag) { create(:framework_flag, framework_question: framework_response.framework_question, question_value: 'Yes') }
    let!(:other_flag) { create(:framework_flag, framework_question: other_framework_response.framework_question, question_value: 'No') }

    let(:value) { 'Yes' }
    let(:other_value) { 'No' }

    let(:bulk_youth_risk_assessment_params) do
      {
        data: [
          {
            id: framework_response_id,
            type: 'framework_responses',
            attributes: {
              value: value,
            },
          },
          {
            id: other_framework_response_id,
            type: 'framework_responses',
            attributes: {
              value: other_value,
            },
          },
        ],
      }
    end

    context 'when successful' do
      before { bulk_update_framework_responses }

      it_behaves_like 'an endpoint that responds with success 204'

      it 'updates youth_risk_assessment status' do
        expect(youth_risk_assessment.reload.status).to eq('completed')
      end
    end

    context 'when unsuccessful' do
      before { bulk_update_framework_responses }

      context 'when the youth_risk_assessment_id is not found' do
        let(:youth_risk_assessment_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find YouthRiskAssessment with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'when youth_risk_assessment confirmed' do
        let(:youth_risk_assessment) { create(:youth_risk_assessment, :confirmed) }
        let(:detail_403) { "Can't update framework_responses because assessment is confirmed" }

        it_behaves_like 'an endpoint that responds with error 403'
      end
    end
  end
end
