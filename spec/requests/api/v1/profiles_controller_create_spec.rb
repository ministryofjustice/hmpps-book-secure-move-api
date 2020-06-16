# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProfilesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:person) { create(:person_without_profiles) }
  let(:risk_type_1) { create :assessment_question, :risk }
  let(:risk_type_2) { create :assessment_question, :risk }

  describe 'POST /v1/people/:id/profiles' do
    let(:schema) { load_yaml_schema('post_profiles_responses.yaml', version: 'v1') }

    let(:profile_params) do
      {
        data: {
          type: 'profiles',
          attributes: {
            assessment_answers: [
              { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
              { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
            ],
          },
        },
      }
    end

    let(:expected_data) do
      {
        type: 'profiles',
        attributes: {
          assessment_answers: [
            { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
            { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
          ],
        },
      }
    end

    context 'with valid params' do
      before { post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json['data']).to include_json(expected_data)
      end

      it 'creates a new profile' do
        expect {
          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        }.to change(Profile, :count).by(1)
      end
    end

    describe 'updating assessment answers from Nomis' do
      let(:person) { create(:person_without_profiles, prison_number: prison_number) }
      let(:profile_params) do
        {
          data: {
            type: 'profiles',
            attributes: {},
          },
        }
      end

      context 'when the person has a prison_number' do
        let(:prison_number) { 'G5033UT' }

        let(:alerts_response) do
          [
            {
              offender_no: prison_number,
              alert_code: 'ACCU9',
              alert_type: 'MATSTAT',
            },
          ]
        end

        let(:personal_care_needs_response) do
          [
            {
              offender_no: prison_number,
              problem_type: 'FOO',
              problem_code: 'AA',
            },
          ]
        end

        before do
          allow(NomisClient::Alerts).to receive(:get).and_return(alerts_response)
          allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)

          create(:assessment_question, :care_needs_fallback)
          create(:assessment_question, :alerts_fallback)

          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        end

        it 'imports the assessment answers from Nomis' do
          resp = JSON.parse(response.body)

          expected_answers = [
            {
              'category' => 'risk',
              'created_at' => '2020-06-16',
              'imported_from_nomis' => true,
              'key' => 'other_risks',
              'nomis_alert_code' => 'ACCU9',
              'nomis_alert_type' => 'MATSTAT',
              'title' => 'Other Risks',
            },
          ]
          actual_answers = resp.dig('data', 'attributes', 'assessment_answers')

          expect(actual_answers).to include_json(expected_answers)
        end

        context 'when the person does NOT have a prison_number' do
          let(:prison_number) { nil }

          before do
            post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
          end

          it 'does NOT import the assessment answers from Nomis' do
            resp = JSON.parse(response.body)

            expect(resp['data']['attributes']['assessment_answers'].count).to eq(0)
          end
        end
      end
    end

    context 'with a person associated to multiple profiles' do
      it 'maintains previous profiles associated to the person' do
        person = create(:person)

        expect {
          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        }.to change(Profile, :count).from(1).to(2)
      end
    end

    context 'with included relationships' do
      let(:profile_params) do
        {
          include: include_params,
          data: {
            type: 'profiles',
            attributes: {
              assessment_answers: [
                { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
                { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
              ],
            },
          },
        }
      end

      before do
        post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
      end

      context 'when the include query param is empty' do
        let(:include_params) { [] }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when include is nil' do
        let(:include_params) { nil }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including a relationship' do
        let(:include_params) { 'person' }

        it 'includes the relevant relationships' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq

          expect(returned_types).to contain_exactly('people')
        end
      end

      context 'when including a non existing relationship in a query param' do
        let(:include_params) { 'person,non-existent-relationship' }

        it 'responds with error 400' do
          response_error = response_json['errors'].first

          expect(response_error['title']).to eq('Bad request')
          expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
        end
      end
    end

    context 'with a bad request' do
      before { post "/api/v1/people/#{person.id}/profiles", params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when the person_id is not found' do
      before { post '/api/v1/people/foo-bar/profiles', params: profile_params, headers: headers, as: :json }

      let(:detail_404) { "Couldn't find Person with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:detail_401) { 'Token expired or invalid' }
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }

      before { post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
