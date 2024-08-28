# frozen_string_literal: true

require 'rails_helper'
require 'digest'

module Mock
  # NB: the mock class name must be unique in test suite
  class IdempotentController < ApiController
    include Idempotentable

    before_action :validate_idempotency_key
    around_action :idempotent_action

    def authentication_enabled?
      false # NB: disable authentication to simplify tests (it is tested elsewhere)
    end

    def event
      render json: { hello: request.params[:data] }, status: :ok
    end
  end
end

RSpec.describe Mock::IdempotentController, type: :request do
  let(:idempotency_key1) { '11111111-1111-1111-1111-111111111111' }
  let(:idempotency_key2) { '22222222-2222-2222-2222-222222222222' }
  let(:params1) { { data: 'one' } }
  let(:params2) { { data: 'two' } }
  let(:response_json) { JSON.parse(response.body) }

  around do |example|
    Rails.application.routes.draw { post '/mock/event', to: 'mock/idempotent#event' }
    example.run
    Rails.application.reload_routes!
  end

  context 'with two identical requests with the same idempotency key' do
    before do
      post '/mock/event', params: params1, headers: { 'IDEMPOTENCY-KEY': idempotency_key1 }, as: :json
      post '/mock/event', params: params1, headers: { 'IDEMPOTENCY-KEY': idempotency_key1 }, as: :json
    end

    it 'returns a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a valid JSON response' do
      expect(response_json).to eql({ 'hello' => 'one' })
    end
  end

  context 'with two different requests with different idempotency keys' do
    before do
      post '/mock/event', params: params1, headers: { 'IDEMPOTENCY-KEY': idempotency_key1 }, as: :json
      post '/mock/event', params: params2, headers: { 'IDEMPOTENCY-KEY': idempotency_key2 }, as: :json
    end

    it 'returns a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a valid JSON response' do
      expect(response_json).to eql({ 'hello' => 'two' })
    end
  end

  context 'with two different requests with the same idempotency key' do
    before do
      post '/mock/event', params: params1, headers: { 'IDEMPOTENCY-KEY': idempotency_key1 }, as: :json
      post '/mock/event', params: params2, headers: { 'IDEMPOTENCY-KEY': idempotency_key1 }, as: :json
    end

    it 'returns a conflict error' do
      expect(response).to have_http_status(:conflict)
    end

    it 'returns a valid JSON response' do
      expect(response_json['errors'].first).to eql({
        'detail' => 'Idempotency::ConflictError: Conflicting idempotency key: 11111111-1111-1111-1111-111111111111',
        'title' => 'Idempotency Conflict Error',
      })
    end
  end

  context 'with a missing idempotency key' do
    before do
      post '/mock/event', params: params1, as: :json
    end

    it 'returns a bad request error' do
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns a valid JSON response' do
      expect(response_json['errors'].first).to eql({
        'detail' => "Validation failed: Idempotency key can't be blank, Idempotency key is invalid",
        'title' => 'Invalid idempotency_key',
      })
    end
  end

  context 'with an invalid idempotency key' do
    before do
      post '/mock/event', params: params1, headers: { 'IDEMPOTENCY-KEY': 'foo bar' }, as: :json
    end

    it 'returns a bad request error' do
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns a valid JSON response' do
      expect(response_json['errors'].first).to eql({
        'detail' => 'Validation failed: Idempotency key is invalid',
        'title' => 'Invalid idempotency_key',
      })
    end
  end
end
