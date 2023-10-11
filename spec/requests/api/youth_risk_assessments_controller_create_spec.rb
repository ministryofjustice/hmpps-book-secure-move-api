# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::YouthRiskAssessmentsController do
  describe 'POST /youth_risk_assessments' do
    subject(:post_youth_risk_assessment) do
      post '/api/youth_risk_assessments', params: youth_risk_assessment_params, headers:, as: :json
    end

    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:person) { create(:person) }
    let(:profile) { create(:profile, person:) }
    let(:profile_id) { profile.id }
    let(:move) { create(:move, :from_stc_to_court, profile:) }
    let(:move_id) { move.id }
    let(:framework) { create(:framework, :youth_risk_assessment, framework_questions: [build(:framework_question, section: 'risk-information', prefill: true)]) }
    let(:framework_version) { framework.version }

    let(:youth_risk_assessment_params) do
      {
        data: {
          "type": 'youth_risk_assessments',
          "attributes": {
            "version": framework_version,
          },
          "relationships": {
            "move": {
              "data": {
                "id": move_id,
                "type": 'moves',
              },
            },
          },
        },
        include: 'responses,flags',
      }
    end

    before { post_youth_risk_assessment }

    context 'when successful' do
      let(:schema) { load_yaml_schema('post_youth_risk_assessment_responses.yaml') }
      let(:data) do
        {
          "id": YouthRiskAssessment.last.id,
          "type": 'youth_risk_assessments',
          "attributes": {
            "version": framework_version,
            "status": 'not_started',
            "confirmed_at": nil,
            "nomis_sync_status": [],
          },
          "meta": {
            'section_progress' => [
              {
                "key": 'risk-information',
                "status": 'not_started',
              },
            ],
          },
          "relationships": {
            "profile": {
              "data": {
                "id": profile_id,
                "type": 'profiles',
              },
            },
            "move": {
              "data": {
                "id": move_id,
                "type": 'moves',
              },
            },
            "framework": {
              "data": {
                "id": framework.id,
                "type": 'frameworks',
              },
            },
            "responses": {
              "data": [
                {
                  "id": FrameworkResponse.last.id,
                  "type": 'framework_responses',
                },
              ],
            },
            "flags": {
              "data": [],
            },
            "prefill_source": {
              "data": nil,
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when prefilling from previous youth risk assessment' do
      subject(:post_youth_risk_assessment) do
        previous_pesron_escort_record

        post '/api/youth_risk_assessments', params: youth_risk_assessment_params, headers:, as: :json
      end

      let(:previous_profile) { create(:profile, person:) }
      let(:previous_pesron_escort_record) do
        create(:youth_risk_assessment, :confirmed, profile: previous_profile, framework_responses: [create(:string_response, framework_question: framework.framework_questions.first)])
      end
      let(:youth_risk_assessment_params) do
        {
          data: {
            "type": 'youth_risk_assessments',
            "attributes": {
              "version": framework_version,
            },
            "relationships": {
              "move": {
                "data": {
                  "id": move_id,
                  "type": 'moves',
                },
              },
            },
          },
          include: 'responses,flags',
        }
      end
      let(:schema) { load_yaml_schema('post_youth_risk_assessment_responses.yaml') }
      let(:new_youth_risk_assessment) { YouthRiskAssessment.order(created_at: :desc).first }
      let(:data) do
        {
          "id": new_youth_risk_assessment.id,
          "type": 'youth_risk_assessments',
          "attributes": {
            "version": framework_version,
            "status": 'not_started',
            "confirmed_at": nil,
            "nomis_sync_status": [],
          },
          "meta": {
            'section_progress' => [
              {
                "key": 'risk-information',
                "status": 'not_started',
              },
            ],
          },
          "relationships": {
            "profile": {
              "data": {
                "id": profile_id,
                "type": 'profiles',
              },
            },
            "move": {
              "data": {
                "id": move_id,
                "type": 'moves',
              },
            },
            "framework": {
              "data": {
                "id": framework.id,
                "type": 'frameworks',
              },
            },
            "responses": {
              "data": [
                {
                  "id": new_youth_risk_assessment.reload.framework_responses.last.id,
                  "type": 'framework_responses',
                },
              ],
            },
            "flags": {
              "data": [],
            },
            "prefill_source": {
              "data": {
                "id": previous_pesron_escort_record.id,
                "type": 'youth_risk_assessments',
              },
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with a bad request' do
        let(:youth_risk_assessment_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'when the move is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'when move location is not from sch or stc' do
        let(:move) { create(:move, profile:) }
        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => "Move 'from location' must be from either a secure training centre or a secure children's home",
              'source' => { 'pointer' => '/data/attributes/move' },
            },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end

      context 'when a youth risk assessment already exists on a profile' do
        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Profile has already been taken',
              'source' => { 'pointer' => '/data/attributes/profile' },
              'code' => 'taken',
            },
          ]
        end

        before do
          post '/api/youth_risk_assessments', params: youth_risk_assessment_params, headers:, as: :json
          post '/api/youth_risk_assessments', params: youth_risk_assessment_params, headers:, as: :json
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end

      context 'when a youth risk assessment already exists on a profile and unique index error thrown' do
        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Profile has already been taken',
              'source' => { 'pointer' => '/data/attributes/profile' },
              'code' => 'taken',
            },
          ]
        end

        before do
          youth_risk_assessment = YouthRiskAssessment.new
          allow(YouthRiskAssessment).to receive(:new).and_return(youth_risk_assessment)
          allow(youth_risk_assessment).to receive(:build_responses!).and_raise(PG::UniqueViolation, 'duplicate key value violates unique constraint')

          post '/api/youth_risk_assessments', params: youth_risk_assessment_params, headers:, as: :json
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end

      context 'with a reference to a missing framework' do
        let(:framework_version) { '0.2.1' }
        let(:detail_404) { 'Couldn\'t find Framework with [WHERE "frameworks"."version" = $1 AND "frameworks"."name" = $2]' }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with no framework' do
        let(:youth_risk_assessment_params) do
          {
            data: {
              "type": 'youth_risk_assessments',
              "relationships": {
                "move": {
                  "data": {
                    "id": move_id,
                    "type": 'moves',
                  },
                },
              },
            },
          }
        end
        let(:detail_404) { 'Couldn\'t find Framework with [WHERE "frameworks"."version" IS NULL AND "frameworks"."name" = $1]' }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
