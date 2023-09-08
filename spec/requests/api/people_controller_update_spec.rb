# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'PUT /api/v1/people' do
    let!(:person) { create :person }
    let(:schema) { load_yaml_schema('put_people_responses.yaml') }
    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :assessment_question, :risk }
    let(:risk_type_2) { create :assessment_question, :risk }
    let(:gender_additional_information) { nil }
    let(:pnc) { "17/35#{Person.pnc_checkdigit('170000035')}" }
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
              { title: 'Escape risk',
                assessment_question_id: risk_type_1.id,
                comments: 'Needs an inhaler',
                nomis_alert_type: 'alert type',
                nomis_alert_type_description: 'alert type description',
                nomis_alert_code: 'alert code',
                nomis_alert_description: 'alert description',
                imported_from_nomis: 'true',
                created_at: '2020-01-30',
                expires_at: '2020-12-30' },

              { title: 'Violent', assessment_question_id: risk_type_2.id },
            ],
            identifiers: [
              { identifier_type: 'police_national_computer', value: pnc },
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
              { title: risk_type_1.title,
                assessment_question_id: risk_type_1.id,
                comments: 'Needs an inhaler',
                nomis_alert_type: 'alert type',
                nomis_alert_type_description: 'alert type description',
                nomis_alert_code: 'alert code',
                nomis_alert_description: 'alert description',
                imported_from_nomis: 'true',
                created_at: '2020-01-30',
                expires_at: '2020-12-30' },
              { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
            ],
            identifiers: [
              { identifier_type: 'police_national_computer', value: pnc },
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
        expect(JSON.parse(response.body)).to include_json(data: expected_data.merge(id: person.id))
      end

      it 'updates an existing person' do
        expect {
          put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        }.to change(Person, :count).by(0)
      end

      it 'changes the first_names' do
        put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        expect(person.reload.first_names).to include(expected_data[:attributes][:first_names])
      end

      describe 'webhook and email notifications' do
        before do
          allow(Notifier).to receive(:prepare_notifications)
          put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        end

        it 'calls the notifier when updating a person' do
          expect(Notifier).to have_received(:prepare_notifications).with(topic: person, action_name: 'update')
        end
      end
    end

    context 'with gender_additional_information' do
      let(:gender_additional_information) { 'some additional info' }

      it 'updates an existing person' do
        put "/api/v1/people/#{person.id}", params: person_params, headers: headers, as: :json
        expect(person.reload.gender_additional_information).to eq gender_additional_information
      end
    end

    context 'with a bad request' do
      before { put "/api/v1/people/#{person.id}", params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
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
