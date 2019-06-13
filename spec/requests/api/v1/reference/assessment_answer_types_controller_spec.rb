# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::AssessmentAnswerTypesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/assessment_answer_types' do
    let(:schema) { load_json_schema('get_assessment_answer_types_responses.json') }

    let!(:assessment_answer_type) { FactoryBot.create(:assessment_answer_type) }
    let(:data) do
      [
        {
          id: assessment_answer_type.id,
          type: 'assessment_answer_types',
          attributes: {
            category: 'health',
            user_type: 'prison',
            alert_type: 'M',
            alert_code: 'MSI',
            description: 'Sight Impaired'
          }
        }
      ]
    end

    let(:params) { {} }

    before do
      get '/api/v1/reference/assessment_answer_types', headers: headers, params: params
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    describe 'filtering' do
      let(:category_filter) { :health }
      let(:user_type_filter) { :prison }
      let(:params) { { filter: { category: category_filter, user_type: user_type_filter } } }
      let(:data) do
        [
          {
            id: assessment_answer_type.id
          }
        ]
      end

      context 'with matching filters' do
        it 'returns the matching item' do
          expect(response_json).to include_json(data: data)
        end
      end

      context 'with a mis-matched `user_type` filter' do
        let(:user_type_filter) { :police }

        it 'does not return the mis-matched item' do
          expect(response_json).not_to include_json(data: data)
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
