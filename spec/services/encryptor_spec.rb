# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Encryptor do
  subject { described_class }

  context 'when encrypting' do
    let(:message) { 'unencrypted text' }
    let(:encrypted_message) { subject.encrypt(message) }
    let(:decrypted_message) { subject.decrypt(encrypted_message) }

    it 'hides the original message' do
      expect(message).not_to eq(encrypted_message)
    end

    it 'returns the original message when decrypted' do
      expect(decrypted_message).to eq(message)
    end
  end
end
