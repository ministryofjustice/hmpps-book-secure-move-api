# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::FrameworksController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'Authorization' => "Bearer #{access_token}" } }
  let(:response_json) { JSON.parse(response.body) }
  let(:params) { {} }

  describe 'GET /api/reference/frameworks/:id' do
    let(:schema) { load_yaml_schema('get_framework_responses.yaml') }

    let(:framework) { create(:framework) }
    let(:dependent_question) { create(:framework_question, framework: framework) }
    let(:question) { create(:framework_question, framework: framework, dependents: [dependent_question]) }

    let(:data) do
      {
        type: 'frameworks',
        attributes: {
          name: framework.name,
          version: framework.version,
        },
        relationships: {},
      }
    end

    before do
      create(:framework_flag, framework_question: question)

      get "/api/reference/frameworks/#{framework_id}", headers: headers, params: params
    end

    context 'when successful' do
      let(:framework_id) { framework.id }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'with all supported includes' do
      let(:framework_id) { framework.id }
      let(:params) do
        {
          include: 'questions,questions.descendants.**,questions.flags,questions.descendants.flags',
        }
      end

      let(:expected_relationships) do
        {
          relationships: {
            questions: {
              data: UnorderedArray(
                {
                  id: question.id,
                  type: 'framework_questions',
                },
                {
                  id: dependent_question.id,
                  type: 'framework_questions',
                },
              ),
            },
          },
        }
      end

      it 'returns the correct relationships' do
        expect(response_json).to include_json(data: expected_relationships)
      end

      it 'returns the correct includes' do
        included_types = response_json['included'].map { |i| i['type'] }
        expect(included_types).to match_array(%w[framework_flags framework_questions framework_questions])
      end
    end

    context 'when resource is not found' do
      let(:framework_id) { 'ont-believe-it' }
      let(:detail_404) { "Couldn't find Framework with 'id'=ont-believe-it" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
