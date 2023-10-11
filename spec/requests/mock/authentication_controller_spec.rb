# frozen_string_literal: true

require 'rails_helper'

module Mock
  # NB: the mock class name must be unique in test suite
  class AuthenticationController < ApiController
    def secure
      render json: { hello: 'world' }, status: :ok
    end
  end
end

RSpec.describe Mock::AuthenticationController, type: :request do
  include_context 'with supplier with spoofed access token'

  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('error_responses.yaml') }
  let(:detail_401) { 'Token expired or invalid' }

  around do |example|
    Rails.application.routes.draw { get '/mock/secure', to: 'mock/authentication#secure' }
    example.run
    Rails.application.reload_routes!
  end

  before { get '/mock/secure', headers: }

  context 'with valid authentication' do
    it 'returns a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'sets the correct content type header' do
      expect(response.headers['Content-Type']).to include('application/vnd.api+json')
    end

    it 'returns a valid 200 JSON response' do
      expect(response_json).to eql({ 'hello' => 'world' })
    end
  end

  context 'without authentication headers' do
    let(:headers) { nil }

    it_behaves_like 'an endpoint that responds with error 401'
  end

  context 'without a valid access token' do
    let(:access_token) { 'FOOBAR' }

    it_behaves_like 'an endpoint that responds with error 401'
  end
end
