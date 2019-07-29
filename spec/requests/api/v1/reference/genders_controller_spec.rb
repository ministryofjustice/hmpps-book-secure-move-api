# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::GendersController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/genders' do
    let(:schema) { load_json_schema('get_genders_responses.json') }

    let(:data) do
      [
        {
          type: 'genders',
          attributes: {
            key: 'female',
            title: 'Female',
            disabled_at: nil
          }
        },
        {
          type: 'genders',
          attributes: {
            key: 'male',
            title: 'Male',
            disabled_at: nil
          }
        },
        {
          type: 'genders',
          attributes: {
            key: 'r',
            title: 'Refused',
            disabled_at: '2019-07-24T00:00:00Z'
          }
        }
      ]
    end

    before do
      data.each { |gender| Gender.create!(gender[:attributes]) }

      get '/api/v1/reference/genders', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
