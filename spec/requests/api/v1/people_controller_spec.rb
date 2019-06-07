# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::PeopleController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'POST /people' do
    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :profile_attribute_type, :risk }
    let(:risk_type_2) { create :profile_attribute_type, :risk }
    let(:person_params) do
      {
        data: {
          type: 'people',
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

      it 'returns a success code' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(response).to have_http_status(:created)
      end

      it 'creates a new person' do
        expect do
          post '/api/v1/people', params: person_params, headers: headers, as: :json
        end.to change(Person, :count).by(1)
      end

      it 'returns the correct data' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        require 'pry'; binding.pry
        expect(JSON.parse(response.body)).to include_json(data: expected_data.merge(id: Person.last&.id))
      end

      it 'sets the correct content type header' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'when not authorized' do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns a invalid media type error code' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(response).to have_http_status(415)
      end
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

      let(:errors) do
        [
          {
            'source' => { 'pointer' => '/data/attributes/last_name' },
            'code' => 'validation_error',
            'detail' => "Last name can't be blank"
          }
        ]
      end

      it 'returns unprocessable entity error code' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(response).to have_http_status(422)
      end

      it 'returns errors in the body of the response' do
        post '/api/v1/people', params: person_params, headers: headers, as: :json
        expect(JSON.parse(response.body)).to include_json(errors: errors)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('post_people_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'when successful' do
        it 'returns a valid 201 JSON response' do
          post '/api/v1/people', params: person_params, headers: headers, as: :json
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/201')).to be true
        end
      end

      context 'with a bad request' do
        it 'returns a valid 400 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: person_params, headers: headers, as: :json
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/400')).to be true
        end
      end

      context 'when not authorized' do
        it 'returns a valid 401 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: person_params, headers: headers, as: :json
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          post '/api/v1/people', params: person_params, headers: headers, as: :json
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end

      context 'with validation errors' do
        it 'returns a valid 422 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: person_params, headers: headers, as: :json
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/422')).to be true
        end
      end
    end
  end
end
