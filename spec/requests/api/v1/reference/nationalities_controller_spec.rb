# frozen_string_literal: true

RSpec.describe Api::V1::Reference::NationalitiesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/nationalities' do
    let(:schema) { load_json_schema('get_nationalities_responses.json') }

    let(:data) do
      [
        {
          type: 'nationalities',
          attributes: {
            key: 'british',
            title: 'British',
          },
        },
        {
          type: 'nationalities',
          attributes: {
            key: 'french',
            title: 'French',
          },
        },
      ]
    end

    before do
      data.each { |nationality| Nationality.create!(nationality[:attributes]) }

      get '/api/v1/reference/nationalities', headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
