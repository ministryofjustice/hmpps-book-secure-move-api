# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::Reference::ProfileAttributeTypesController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'GET /api/v1/reference/profile_attribute_types' do
    let!(:profile_attribute_type) do
      FactoryBot.create(
        :profile_attribute_type,
        category: 'health',
        user_type: 'prison',
        alert_type: 'M',
        alert_code: 'MSI',
        description: 'Sight Impaired'
      )
    end
    let(:expected_data) do
      [
        {
          id: profile_attribute_type.id,
          type: 'profile_attribute_types',
          attributes: {
            category: 'health',
            user_type: 'prison',
            alert_type: 'M',
            alert_code: 'MSI',
            description: 'Sight Impaired'
          }
        }
      ]
    end

    context 'with the correct CONTENT_TYPE header' do
      it 'returns a success code' do
        get '/api/v1/reference/profile_attribute_types', headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        get '/api/v1/reference/profile_attribute_types', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        get '/api/v1/reference/profile_attribute_types', headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'fails if I set the wrong `content-type` header' do
        get '/api/v1/reference/profile_attribute_types', headers: headers
        expect(response.code).to eql '415'
      end
    end

    describe 'filtering' do
      let(:category_filter) { :health }
      let(:user_type_filter) { :prison }
      let(:params) { { filter: { category: category_filter, user_type: user_type_filter } } }
      let(:expected_data) do
        [
          {
            id: profile_attribute_type.id
          }
        ]
      end

      before do
        get '/api/v1/reference/profile_attribute_types', headers: headers, params: params
      end

      context 'with matching filters' do
        it 'returns the matching item' do
          expect(JSON.parse(response.body)).to include_json(data: expected_data)
        end
      end

      context 'with a mis-matched `user_type` filter' do
        let(:user_type_filter) { :police }

        it 'does not return the mis-matched item' do
          expect(JSON.parse(response.body)).not_to include_json(data: expected_data)
        end
      end

      context 'with a mis-matched `category` filter' do
        let(:category_filter) { :risk }

        it 'does not return the mis-matched item' do
          expect(JSON.parse(response.body)).not_to include_json(data: expected_data)
        end
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_profile_attribute_types_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          get '/api/v1/reference/profile_attribute_types', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          get '/api/v1/reference/profile_attribute_types', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end
end
