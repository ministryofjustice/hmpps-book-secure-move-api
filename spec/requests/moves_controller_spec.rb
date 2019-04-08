# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovesController do
  let(:valid_headers) { { 'CONTENT_TYPE': 'application/vnd.api+json' } }

  describe 'GET /moves' do
    context 'when there is no data' do
      it 'returns a success code' do
        get '/moves', headers: valid_headers
        expect(response).to be_successful
      end

      it 'returns an empty list' do
        get '/moves', headers: valid_headers
        expect(JSON.parse(response.body)).to include_json(data: [])
      end

      it 'fails if I set the wrong `content-type` header' do
        get '/moves', headers: { 'CONTENT_TYPE': 'application/xml' }
        pending 'content-type header enforcement not implemented yet'
        expect(response).not_to be_successful
      end
    end
  end
end
