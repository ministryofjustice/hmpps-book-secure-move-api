# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController, with_client_authentication: true do
  let!(:application) { Doorkeeper::Application.create(name: 'test') }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'PUT /api/v1/people' do
    let!(:person) { create :person }
    let(:schema) { load_json_schema('put_people_responses.json') }
    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :assessment_question, :risk }
    let(:risk_type_2) { create :assessment_question, :risk }
    let(:gender_additional_information) { nil }
    let(:person_params) do
      {
        data: {
          type: 'people',
          id: person.id,
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1),
            assessment_answers: [
              { title: 'Escape risk', assessment_question_id: risk_type_1.id },
              { title: 'Violent', assessment_question_id: risk_type_2.id },
            ],
            identifiers: [
              { identifier_type: 'police_national_computer', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' },
            ],
            gender_additional_information: gender_additional_information,
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
        }
      end

      context 'with valid params' do
        before { put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with success 200'
      end

      it 'returns the correct data' do
        put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        expect(JSON.parse(response.body)).to include_json(data: expected_data.merge(id: Person.last&.id))
      end

      it 'updates an existing person' do
        expect do
          put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        end.to change(Person, :count).by(0)
      end

      it 'changes the assessment answers' do
        put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        expect(person.latest_profile.reload.first_names).to include(expected_data[:attributes][:first_names])
      end
    end

    context 'with gender_additional_information' do
      let(:gender_additional_information) { 'some additional info' }

      it 'updates an existing person' do
        put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        expect(person.reload.latest_profile.gender_additional_information).to eq gender_additional_information
      end
    end

    context 'with a bad request' do
      before { put "/api/v1/people/#{person.id}", params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when not authorized' do
      before { put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json }

      let(:headers) { { 'CONTENT_TYPE': content_type } }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'with validation errors' do
      let(:person_params) do
        {
          data: {
            type: 'people',
            attributes: { last_name: '' },
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

      before { put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
