# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::YouthRiskAssessmentsController do
  describe 'GET /youth_risk_assessments/:youth_risk_assessment_id' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:framework_question) { build(:framework_question, section: 'risk-information') }
    let(:flag) { build(:framework_flag, framework_question:) }
    let(:framework) { create(:framework, framework_questions: [framework_question]) }
    let(:youth_risk_assessment) do
      youth_risk_assessment = create(:youth_risk_assessment)
      create(:string_response, framework_question:, responded: true, framework_flags: [flag], assessmentable: youth_risk_assessment)

      youth_risk_assessment
    end
    let(:youth_risk_assessment_id) { youth_risk_assessment.id }

    before do
      youth_risk_assessment.update_status_and_progress!
      get "/api/youth_risk_assessments/#{youth_risk_assessment_id}?include=flags,responses", headers:, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('get_youth_risk_assessment_responses.yaml') }
      let(:data) do
        {
          "id": youth_risk_assessment.id,
          "type": 'youth_risk_assessments',
          "attributes": {
            "version": youth_risk_assessment.framework.version,
            "completed_at": youth_risk_assessment.completed_at.iso8601,
            "status": 'completed',
          },
          "meta": {
            'section_progress' => [
              {
                "key": 'risk-information',
                "status": 'completed',
              },
            ],
          },
          "relationships": {
            "profile": {
              "data": {
                "id": youth_risk_assessment.profile.id,
                "type": 'profiles',
              },
            },
            "framework": {
              "data": {
                "id": youth_risk_assessment.framework.id,
                "type": 'frameworks',
              },
            },
            "responses": {
              "data": [
                {
                  "id": youth_risk_assessment.framework_responses.first.id,
                  "type": 'framework_responses',
                },
              ],
            },
            "flags": {
              "data": [
                {
                  "id": flag.id,
                  "type": 'framework_flags',
                },
              ],
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when attempting to access an unknown youth risk assessment' do
        let(:youth_risk_assessment_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find YouthRiskAssessment with 'id'=#{youth_risk_assessment_id}" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
