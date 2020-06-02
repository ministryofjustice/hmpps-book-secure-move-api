# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::PeopleController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'POST /people' do
    let(:schema) { load_yaml_schema('post_people_responses.yaml', version: 'v2') }

    let(:profile) { create :profile }
    let(:risk_type_1) { create :assessment_question, :risk }
    let(:risk_type_2) { create :assessment_question, :risk }

    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1),

            identifiers: [
              { identifier_type: 'police_national_computer', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' },
            ],
          },
          relationships: {
            ethnicity: {
              data: {
                id: profile.id,
                type: 'profiles',
              },
            },
          },
        },
      }
    end

    context 'when successful' do
      let(:expected_data) do
        {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1).iso8601,

            identifiers: [
              { identifier_type: 'police_national_computer', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' },
            ],
          },
          relationships: {
            gender: {
              data: {
                type: 'genders',
                id: gender.id,
              },
            },
            ethnicity: {
              data: {
                type: 'ethnicities',
                id: ethnicity.id,
              },
            },
          },
        }
      end

      let(:expected_included) do
        [
          {
            id: profile.id,
            type: 'profiles',
            attributes: {
              assessment_answers: [
                  { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
                  { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
              ],
            },
          },
        ]
      end

      context 'with valid params' do
        before { post '/api/v2/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with success 201'
      end

    end
  end
end
