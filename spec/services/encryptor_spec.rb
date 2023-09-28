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

  context 'when encrypted_message is nil' do
    let(:decrypted_message) { subject.decrypt(nil) }

    it { expect(decrypted_message).to be_nil }
  end

  describe 'hmac' do
    subject { described_class.hmac('foo', 'bar') }

    it { is_expected.to eql('+TILrwJJFp5zhQzWFW3tAQbiu2rYyrAbe7vr5tEGUxc=') }
  end

  # Since Rails 7.0, new applications use SHA256 by default, but we still want
  # to use SHA1 to be compatible with secrets created by Rails 6.1.
  describe 'decrypt' do
    subject { described_class.decrypt(sha1_secret) }

    let(:sha1_key) do
      ActiveSupport::KeyGenerator.new(
        Rails.application.secret_key_base,
        { hash_digest_class: OpenSSL::Digest::SHA1 },
      ).generate_key(
        ENV.fetch('ENCRYPTOR_SALT'),
        ActiveSupport::MessageEncryptor.key_len,
      )
    end

    let(:sha1_secret) do
      ActiveSupport::MessageEncryptor.new(sha1_key).encrypt_and_sign('decrypted_secret')
    end

    it { is_expected.to eql('decrypted_secret') }
  end
end
