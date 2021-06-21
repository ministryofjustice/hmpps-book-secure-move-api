# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::AssessmentQuestionsController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/assessment_questions' do
    let(:schema) { load_yaml_schema('get_assessment_questions_responses.yaml') }

    let!(:assessment_question) { FactoryBot.create(:assessment_question) }
    let(:data) do
      [
        {
          id: assessment_question.id,
          type: 'assessment_questions',
          attributes: {
            category: 'health',
            title: 'Sight Impaired',
          },
        },
      ]
    end

    let(:params) { {} }

    before do
      get '/api/v1/reference/assessment_questions', params: params, headers: { 'Authorization' => 'Bearer spoofed-token' }
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    describe 'filtering' do
      let(:category_filter) { :health }
      let(:params) { { filter: { category: category_filter } } }
      let(:data) do
        [
          {
            id: assessment_question.id,
          },
        ]
      end

      context 'with matching filters' do
        it 'returns the matching item' do
          expect(response_json).to include_json(data: data)
        end
      end

      context 'with a mis-matched `category` filter' do
        let(:category_filter) { :risk }

        it 'does not return the mis-matched item' do
          expect(response_json).not_to include_json(data: data)
        end
      end
    end
  end
end
