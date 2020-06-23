# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiController, type: :request do
  # include_context 'with supplier with access token'
  # let(:headers) { { 'CONTENT_TYPE': 'application/vnd.api+json', 'IDEMPOTENCY_KEY': idempotency_key } }
  let(:idempotency_key1) { '11111111-1111-1111-1111-111111111111' }
  let(:idempotency_key2) { '22222222-2222-2222-2222-222222222222' }
  let(:params1) { { data: 'one' } }
  let(:params2) { { data: 'two' } }

  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('error_responses.yaml') }
  let(:detail_401) { 'Token expired or invalid' }
  let(:mock_redis) { MockRedis.new }

  before do
    allow(Redis).to receive(:new) { mock_redis }
    described_class.class_eval do
      around_action :idempotent_action
      def authentication_enabled?
        false # NB: disable authentication to simplify tests (it is tested elsewhere)
      end
      def custom
        render json: { hello: 'world' }, status: :ok
      end
    end
    Rails.application.routes.draw do
      post '/custom', to: 'api#custom'
    end
    # # first request
    # post '/custom', params: params, headers: headers, as: :json
    # # duplicated request
    # post '/custom', params: duplicated_params, headers: headers, as: :json
  end

  after do
    Rails.application.reload_routes!
  end


  context 'with two identical requests' do
    before do
      post '/custom', params: params1, headers:  { IDEMPOTENCY_KEY: idempotency_key1 }, as: :json
      post '/custom', params: params1, headers:  { IDEMPOTENCY_KEY: idempotency_key1 }, as: :json
    end

  end

  context 'with valid idempotency_key' do
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

  context 'with a duplicated request' do
    before do
      # post the same request again within the time period
      post '/custom', params: params, headers: headers, as: :json
    end

    it 'returns a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a valid 200 JSON response' do
      expect(response_json).to eql({ 'hello' => 'world' })
    end
  end

  context 'with the same idempotency key but different request' do
    before do
      # post the same idempotency key but different request
      post '/custom', params: { different: true }, headers: headers, as: :json
    end

    it_behaves_like 'an endpoint that responds with error 409'
  end

  #
  # context 'with valid authentication' do
  #   it 'returns a success code' do
  #     expect(response).to have_http_status(:ok)
  #   end
  #
  #   it 'sets the correct content type header' do
  #     expect(response.headers['Content-Type']).to include('application/vnd.api+json')
  #   end
  #
  #   it 'returns a valid 200 JSON response' do
  #     expect(response_json).to eql({ 'hello' => 'world' })
  #   end
  # end
  #
  # context 'without authentication headers' do
  #   let(:headers) { nil }
  #
  #   it_behaves_like 'an endpoint that responds with error 401'
  # end
  #
  # context 'without a valid access token' do
  #   let(:access_token) { 'FOOBAR' }
  #
  #   it_behaves_like 'an endpoint that responds with error 401'
  # end
end
