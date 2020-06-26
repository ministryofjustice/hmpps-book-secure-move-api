# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotency::ConflictError do
  it { expect(described_class).to be < StandardError }

  describe 'message' do
    let(:message) { described_class.new('11111111-1111-1111-1111-111111111111').message }

    it 'has a message' do
      expect(message).to eql('Conflicting idempotency key: 11111111-1111-1111-1111-111111111111')
    end
  end
end
