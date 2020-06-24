# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotency::HeadersValidator do
  subject(:headers_validator) { described_class.new(headers) }

  let(:headers) { { key_name => key_value } }
  let(:key_name) { 'IDEMPOTENCY_KEY' }
  let(:key_value) { '5fb8a608-6956-46e0-a7c5-1c8edf715d77' }

  context 'when valid' do
    it { is_expected.to be_valid }
  end

  describe 'key' do
    context 'when missing' do
      let(:key_name) { 'missing' }

      it { is_expected.not_to be_valid }
    end

    context 'when lower case' do
      let(:key_name) { 'idempotency_key' }

      it { is_expected.to be_valid }
    end

    context 'when mixed case with a hyphen' do
      let(:key_name) { 'Idempotency-Key' }

      it { is_expected.to be_valid }
    end
  end

  describe 'value' do
    context 'when invalid' do
      let(:key_value) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:key_value) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
