# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /people' do
    let(:schema) { load_json_schema('post_people_responses.json') }

    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :assessment_answer_type, :risk }
    let(:risk_type_2) { create :assessment_answer_type, :risk }
    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1),
            assessment_answers: [
              { title: 'Escape risk', assessment_answer_type_id: risk_type_1.id },
              { title: 'Violent', assessment_answer_type_id: risk_type_2.id }
            ],
            identifiers: [
              { identifier_type: 'pnc_number', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' }
            ]
          },
          relationships: {
            ethnicity: {
              data: {
                id: ethnicity.id,
                type: 'ethnicities'
              }
            },
            gender: {
              data: {
                id: gender.id,
                type: 'genders'
              }
            }
          }
        }
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
              { title: 'Escape risk', assessment_answer_type_id: risk_type_1.id },
              { title: 'Violent', assessment_answer_type_id: risk_type_2.id }
            ],
            identifiers: [
              { identifier_type: 'pnc_number', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' }
            ]
          }
        }
      end

      context 'with valid params' do
        before { post '/api/v1/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      it 'returns the correct data' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(response_json).to include_json(data: expected_data.merge(id: Person.last&.id))
      end

      it 'creates a new person' do
        expect do
          post '/api/v1/people', params: person_params, headers: headers, as: :json
        end.to change(Person, :count).by(1)
      end
    end

    context 'with a bad request' do
      before { post '/api/v1/people', params: nil, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      before { post '/api/v1/people', params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { post '/api/v1/people', params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      let(:person_params) do
        {
          data: {
            type: 'people',
            attributes: { first_names: 'Bob' }
          }
        }
      end

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Last name can't be blank",
            'source' => { 'pointer' => '/data/attributes/last_name' },
            'code' => 'blank'
          }
        ]
      end

      before { post '/api/v1/people', params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
