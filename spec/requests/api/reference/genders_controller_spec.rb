# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::GendersController do
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => 'Bearer spoofed-token') }

  describe 'GET /api/v1/reference/genders' do
    let(:schema) { load_yaml_schema('get_genders_responses.yaml') }

    let(:data) do
      [
        {
          type: 'genders',
          attributes: {
            key: 'female',
            title: 'Female',
            disabled_at: nil,
          },
        },
        {
          type: 'genders',
          attributes: {
            key: 'male',
            title: 'Male',
            disabled_at: nil,
          },
        },
        {
          type: 'genders',
          attributes: {
            key: 'r',
            title: 'Refused',
            disabled_at: '2019-07-24T01:00:00+01:00',
          },
        },
      ]
    end

    before do
      data.each { |gender| Gender.create!(gender[:attributes]) }
    end

    context 'when successful' do
      before do
        get '/api/v1/reference/genders', headers:
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end
  end
end
