# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::ProfilesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:person) { create(:person_without_profiles) }
  let(:risk_type_1) { create :assessment_question, :risk }
  let(:risk_type_2) { create :assessment_question, :risk }

  describe 'POST /v2/people/:id/profiles' do
    let(:schema) { load_yaml_schema('post_profile_responses.yaml', version: 'v2') }

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
      before { post "/api/v2/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json['data']).to include_json(expected_data)
      end

      it 'creates a new profile' do
        expect {
          post "/api/v2/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        }.to change(Profile, :count).by(1)
      end
    end

    context 'with a person associated to multiple profiles' do
      it 'maintains previous profiles associated to the person' do
        person = create(:person)

        expect {
          post "/api/v2/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        }.to change(Profile, :count).from(1).to(2)
      end
    end

    context 'with a bad request' do
      before { post "/api/v2/people/#{person.id}/profiles", params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:detail_401) { 'Token expired or invalid' }
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }

      before { post "/api/v2/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { post "/api/v2/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
