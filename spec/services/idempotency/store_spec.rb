# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotency::Store do
  include_context 'with mock redis'

  subject(:store) { described_class.new(idempotency_key, request_hash) }

  let(:idempotency_key) { SecureRandom.uuid }
  let(:request_hash) { Digest::MD5.base64digest("#{request_method}|#{request_path}|#{request_post}") }
  let(:request_method) { 'POST' }
  let(:request_path) { '/foo/bar' }
  let(:request_post) { 'foo: bar' }
  let(:conflict_key) { "conf|#{idempotency_key}" }
  let(:cache_response_key) { "resp|#{idempotency_key}|#{request_hash}" }

  describe 'set' do
    before do
      store.set(a: 1, b: 2)
    end

    it 'sets a conflict key' do
      expect(mock_redis.get("conf|#{idempotency_key}")).to eql '1'
    end

    it 'sets a cached response' do
      expect(mock_redis.hgetall(cache_response_key)).to eql({ 'a' => '1', 'b' => '2' })
    end

    context 'when the IDEMPOTENCY_KEY is missing' do
      let(:idempotency_key) { nil }

      it 'does not set any redis keys' do
        expect(mock_redis.keys).to be_empty
      end
    end
  end

  describe 'get' do
    context 'when cached response exists' do
      before do
        mock_redis.hmset(cache_response_key, :a, 1, :b, 2)
      end

      it 'returns the cached response' do
        expect(store.get).to eql({ 'a' => '1', 'b' => '2' })
      end
    end

    context 'when the conflict key exists' do
      before do
        mock_redis.set(conflict_key, 1)
      end

      it 'raises a conflict error' do
        expect { store.get }.to raise_error(Idempotency::ConflictError)
      end
    end

    context 'when neither a cached response or conflict key exist' do
      it 'returns nil' do
        expect(store.get).to be_nil
      end
    end

    context 'when the IDEMPOTENCY_KEY is missing' do
      let(:idempotency_key) { nil }

      it 'returns nil' do
        expect(store.get).to be_nil
      end
    end
  end
end
