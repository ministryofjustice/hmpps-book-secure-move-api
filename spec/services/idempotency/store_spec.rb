# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Idempotency::Store do
  subject(:store) { described_class.new(idempotency_key, request_hash) }

  let(:idempotency_key) { SecureRandom.uuid }
  let(:request_hash) { Digest::MD5.base64digest("#{request_method}|#{request_path}|#{request_post}") }
  let(:request_method) { 'POST' }
  let(:request_path) { '/foo/bar' }
  let(:request_post) { 'foo: bar' }
  let(:conflict_key) { "conf|#{idempotency_key}" }
  let(:cache_response_key) { "resp|#{idempotency_key}|#{request_hash}" }
  let(:response) { { a: 1, b: 2 } }

  describe 'write' do
    before do
      store.write(response)
    end

    it 'writes a conflict key' do
      expect(Rails.cache.read("conf|#{idempotency_key}")).to be 1
    end

    it 'writes a cached response' do
      expect(Rails.cache.read(cache_response_key)).to eql(response)
    end

    context 'when the IDEMPOTENCY_KEY is missing' do
      let(:idempotency_key) { nil }

      it 'does not write any cache keys' do
        # NB the only way to inspect a MemoryStore cache's keys
        expect(Rails.cache.instance_variable_get(:@data).keys).to be_empty
      end
    end
  end

  describe 'read' do
    context 'when cached response exists' do
      before do
        Rails.cache.write(cache_response_key, response, expires_in: 10.seconds)
      end

      it 'returns the cached response' do
        expect(store.read).to eql(response)
      end
    end

    context 'when the conflict key exists' do
      before do
        Rails.cache.write(conflict_key, 1, expires_in: 10.seconds)
      end

      it 'raises a conflict error' do
        expect { store.read }.to raise_error(Idempotency::ConflictError)
      end
    end

    context 'when neither a cached response or conflict key exist' do
      it 'returns nil' do
        expect(store.read).to be_nil
      end
    end

    context 'when the IDEMPOTENCY_KEY is missing' do
      let(:idempotency_key) { nil }

      it 'returns nil' do
        expect(store.read).to be_nil
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
