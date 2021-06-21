# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::PeopleController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'POST /people' do
    let(:schema) { load_yaml_schema('post_people_responses.yaml') }

    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :assessment_question, :risk }
    let(:risk_type_2) { create :assessment_question, :risk }
    let(:gender_additional_information) { nil }
    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1),
            gender_additional_information: gender_additional_information,
            assessment_answers: [
              { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
              { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
            ],
            identifiers: [
              { identifier_type: 'police_national_computer', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' },
            ],
          },
          relationships: {
            ethnicity: {
              data: {
                id: ethnicity.id,
                type: 'ethnicities',
              },
            },
            gender: {
              data: {
                id: gender.id,
                type: 'genders',
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
            assessment_answers: [
              { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
              { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
            ],
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
            id: ethnicity.id,
            type: 'ethnicities',
            attributes: {
              key: ethnicity.key,
            },
          },
          {
            id: gender.id,
            type: 'genders',
            attributes: {
              key: gender.key,
            },
          },
        ]
      end

      context 'with valid params' do
        before { post '/api/v1/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      it 'returns the correct data' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json

        expect(response_json).to include_json(data: expected_data.merge(id: Person.last&.id))
      end

      it 'returns the correct included resources' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(response_json).to include_json(included: expected_included)
      end

      it 'creates a new person' do
        expect {
          post '/api/v1/people', params: person_params, headers: headers, as: :json
        }.to change(Person, :count).by(1)
      end

      describe 'webhook and email notifications' do
        before do
          allow(Notifier).to receive(:prepare_notifications)
          post '/api/v1/people', params: person_params, headers: headers, as: :json
        end

        it 'does NOT call the notifier when creating a person' do
          expect(Notifier).not_to have_received(:prepare_notifications)
        end
      end
    end

    context 'with gender_additional_information' do
      let(:gender_additional_information) { 'some additional info' }

      it 'updates an existing person' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(Person.last.reload.gender_additional_information).to eq gender_additional_information
      end
    end

    context 'with a bad request' do
      before { post '/api/v1/people', params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with validation errors' do
      let(:person_params) do
        {
          data: {
            type: 'people',
            attributes: { first_names: 'Bob' },
          },
        }
      end

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Last name can't be blank",
            'source' => { 'pointer' => '/data/attributes/last_name' },
            'code' => 'blank',
          },
        ]
      end

      before { post '/api/v1/people', params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
