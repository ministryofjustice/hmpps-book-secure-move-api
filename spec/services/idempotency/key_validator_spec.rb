# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotency::KeyValidator do
  subject(:key_validator) { described_class.new(idempotency_key) }

  let(:idempotency_key) { '5fb8a608-6956-46e0-a7c5-1c8edf715d77' }

  context 'when valid' do
    it { is_expected.to be_valid }
  end

  context 'when invalid' do
    let(:idempotency_key) { 'foo-bar' }

    it { is_expected.not_to be_valid }
  end

  context 'when nil' do
    let(:idempotency_key) { nil }

    it { is_expected.not_to be_valid }
  end
end
