# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::PeopleController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'POST /people' do
    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1)
          }
        }
      }
    end

    context 'when successful' do
      let(:expected_data) { {} }

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
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with a bad request' do
      it 'returns bad request error code' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(response).to have_http_status(400)
      end
    end

    context 'when not authorized' do
      it 'returns not authorized error code' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(response).to have_http_status(401)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_401)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns a invalid media type error code' do
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(response).to have_http_status(415)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_415)
      end
    end

    context 'with validation errors' do
      let(:errors) do
        [
          {
            'source' => { 'pointer' => '/data/attributes/from_location' },
            'code' => 'validation_error',
            'detail' => 'must exist'
          },
          {
            'source' => { 'pointer' => '/data/attributes/from_location' },
            'code' => 'validation_error',
            'detail' => 'can\'t be blank'
          }
        ]
      end

      it 'returns unprocessable entity error code' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(response).to have_http_status(422)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        post '/api/v1/people', params: { person: person_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('post_people_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'when successful' do
        it 'returns a valid 201 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: { person: person_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/201')).to be true
        end
      end

      context 'with a bad request' do
        it 'returns a valid 400 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: { person: person_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/400')).to be true
        end
      end

      context 'when not authorized' do
        it 'returns a valid 401 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: { person: person_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: { person: person_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end

      context 'with validation errors' do
        it 'returns a valid 422 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/people', params: { person: person_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/422')).to be true
        end
      end
    end
  end
end
