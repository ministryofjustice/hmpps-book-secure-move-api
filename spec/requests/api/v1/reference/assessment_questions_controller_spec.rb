# frozen_string_literal: true

RSpec.describe Api::V1::Reference::AssessmentQuestionsController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/assessment_questions' do
    let(:schema) { load_json_schema('get_assessment_questions_responses.json') }

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
      get '/api/v1/reference/assessment_questions', headers: headers, params: params
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
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
