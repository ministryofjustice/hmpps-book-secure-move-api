# frozen_string_literal: true

require 'rails_helper'

module Mock
  # NB: the mock class name must be unique in test suite
  class SentryController < ApiController
    def show
      render json: { hello: 'world' }, status: :ok
    end
  end
end

RSpec.describe Mock::SentryController, type: :request do
  include_context 'with supplier with spoofed access token'

  let(:response_json) { JSON.parse(response.body) }

  around do |example|
    Rails.application.routes.draw { get '/mock/sentry', to: 'mock/sentry#show' }
    example.run
    Rails.application.reload_routes!
  end

  before do
    allow(Sentry).to receive(:set_tags).and_return({})
  end

  context 'with an X-Transaction-Id header' do
    before do
      get '/mock/sentry', headers: headers.merge({ 'X-Transaction-Id': 'transaction-id' })
    end

    it 'returns a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'sets the correct content type header' do
      expect(response.headers['Content-Type']).to include('application/vnd.api+json')
    end

    it 'returns a valid 200 JSON response' do
      expect(response_json).to eql({ 'hello' => 'world' })
    end

    it 'sets the tag in sentry' do
      expect(Sentry).to have_received(:set_tags).with({ transaction_id: 'transaction-id' })
    end
  end

  context 'without an X-Transaction-Id header' do
    before do
      get '/mock/sentry', headers:
    end

    it 'returns a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'sets the correct content type header' do
      expect(response.headers['Content-Type']).to include('application/vnd.api+json')
    end

    it 'returns a valid 200 JSON response' do
      expect(response_json).to eql({ 'hello' => 'world' })
    end

    it 'sets the tag in sentry to nil' do
      expect(Sentry).to have_received(:set_tags).with({ transaction_id: nil })
    end
  end
end
