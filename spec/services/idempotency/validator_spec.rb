# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotence::Validator do
  subject(:validator) { described_class.new.call(key, required: required) }

  let(:key) { '1234' }
  let(:required) { true }

  context 'with Redis (production/staging)' do
    let(:mock_redis) { MockRedis.new }

    before do
      allow(Redis).to receive(:new) { mock_redis }
      allow(ENV).to receive(:fetch).with('REDIS_URL', nil).and_return('http://some.where')
    end

    context 'when the key does not conflict' do
      it { expect(validator).to be true }
    end

    context 'when the key conflicts with an existing key' do
      before { mock_redis.set(key, 'T') }

      it 'raises a ConflictError' do
        expect { validator }.to raise_error(Idempotence::ConflictError, 'conflicting idempotency key: 1234')
      end
    end

    context 'when the key is nil' do
      let(:key) { nil }

      context 'when the key is required' do
        it 'raises a KeyRequiredError' do
          expect { validator }.to raise_error(Idempotence::KeyRequiredError, 'idempotency key is required')
        end
      end

      context 'when the key is not required' do
        let(:required) { false }

        it 'does not raises an error' do
          expect { validator }.not_to raise_error
        end

        it { is_expected.to be_nil }
      end
    end
  end

  context 'without Redis (development)' do
    before { allow(ENV).to receive(:fetch).with('REDIS_URL', nil).and_return(nil) }

    context 'with any non-blank key' do
      it { is_expected.to be_nil }
    end

    context 'when the key is nil' do
      let(:key) { nil }

      context 'when the key is required' do
        it 'raises a KeyRequiredError' do
          expect { validator }.to raise_error(Idempotence::KeyRequiredError, 'idempotency key is required')
        end
      end

      context 'when the key is not required' do
        let(:required) { false }

        it 'does not raises an error' do
          expect { validator }.not_to raise_error
        end

        it { is_expected.to be_nil }
      end
    end
  end
end
