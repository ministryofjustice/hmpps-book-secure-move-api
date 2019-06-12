# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  describe 'PUT /api/v1/people' do
    let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

    let(:person) { create :person }
    let(:schema) { load_json_schema('post_people_responses.json') }
    let(:response_json) { JSON.parse(response.body) }
    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :profile_attribute_type, :risk }
    let(:risk_type_2) { create :profile_attribute_type, :risk }
    let(:person_params) do
      {
        data: {
          type: 'people',
          id: person.id,
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1),
            risk_alerts: [
              { description: 'Escape risk', profile_attribute_type_id: risk_type_1.id },
              { description: 'Violent', profile_attribute_type_id: risk_type_2.id }
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
            risk_alerts: [
              { description: 'Escape risk', profile_attribute_type_id: risk_type_1.id },
              { description: 'Violent', profile_attribute_type_id: risk_type_2.id }
            ],
            identifiers: [
              { identifier_type: 'pnc_number', value: 'ABC123' },
              { identifier_type: 'prison_number', value: 'XYZ987' }
            ]
          }
        }
      end

      context 'with valid params' do
        before { put '/api/v1/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      it 'returns the correct data' do
        put '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(JSON.parse(response.body)).to include_json(data: expected_data.merge(id: Person.last&.id))
      end

      it 'updates an existing person' do
        expect do
          put '/api/v1/people', params: person_params, headers: headers, as: :json
        end.to change(Person, :count).by(0)
        # TODO: Assertions about data changes
      end
    end

    # context 'with a bad request' do
    #   before { put '/api/v1/people', params: nil, headers: headers, as: :json }

    #   it_behaves_like 'an endpoint that responds with error 400'
    # end

    # context 'when not authorized' do
    #   before { put '/api/v1/people', params: person_params, headers: headers, as: :json }

    #   it_behaves_like 'an endpoint that responds with error 401'
    # end

    # context 'with an invalid CONTENT_TYPE header' do
    #   let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

    #   before { put '/api/v1/people', params: person_params, headers: headers, as: :json }

    #   it_behaves_like 'an endpoint that responds with error 415'
    # end

    # context 'with validation errors' do
    #   let(:person_params) do
    #     {
    #       data: {
    #         type: 'people',
    #         attributes: { first_names: 'Bob' }
    #       }
    #     }
    #   end

    #   let(:errors_422) do
    #     [
    #       {
    #         'title' => 'Unprocessable entity',
    #         'detail' => "Last name can't be blank",
    #         'source' => { 'pointer' => '/data/attributes/last_name' },
    #         'code' => 'blank'
    #       }
    #     ]
    #   end

    #   before { put '/api/v1/people', params: person_params, headers: headers, as: :json }

    #   it_behaves_like 'an endpoint that responds with error 422'
    # end
  end
end
