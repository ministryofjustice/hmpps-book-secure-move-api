# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Encryptor do
  subject { described_class }

  let(:secret_key_base) { SecureRandom.hex(64) }
  let(:encryptor_salt) { SecureRandom.random_bytes(ActiveSupport::MessageEncryptor.key_len) }

  before do
    allow(ENV).to receive(:[]).with('SECRET_KEY_BASE').and_return(secret_key_base)
    allow(ENV).to receive(:[]).with('ENCRYPTOR_SALT').and_return(encryptor_salt)
  end

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
