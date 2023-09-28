# frozen_string_literal: true

require 'base64'
require 'openssl'

class Encryptor
  KEY = ActiveSupport::KeyGenerator.new(
    Rails.application.secret_key_base,
    { hash_digest_class: OpenSSL::Digest::SHA1 },
  ).generate_key(
    ENV.fetch('ENCRYPTOR_SALT'),
    ActiveSupport::MessageEncryptor.key_len,
  ).freeze

  private_constant :KEY

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt(value)
    new.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    new.decrypt_and_verify(value) if value.present?
  end

  def self.hmac(secret, data)
    Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', secret, data))
  end

private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
