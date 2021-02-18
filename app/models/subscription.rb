# frozen_string_literal: true

class Subscription < ApplicationRecord
  include Discard::Model

  # NB: we should not be destroying subscriptions if they have notifications, instead call the discard! method
  has_many :notifications, dependent: :restrict_with_error
  belongs_to :supplier

  validates :supplier, presence: true
  validates :callback_url, url: { allow_nil: true }
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP, allow_nil: true }, presence: false
  validate :email_address_or_callback_url_required

  def secret=(value)
    self[:encrypted_secret] = Encryptor.encrypt(value)
  end

  def username=(value)
    self[:encrypted_username] = Encryptor.encrypt(value)
  end

  def password=(value)
    self[:encrypted_password] = Encryptor.encrypt(value)
  end

  def secret
    Encryptor.decrypt(encrypted_secret)
  end

  def username
    Encryptor.decrypt(encrypted_username)
  end

  def password
    Encryptor.decrypt(encrypted_password)
  end

private

  def email_address_or_callback_url_required
    errors.add(:callback_url, 'is required if email_address is blank') if callback_url.blank? && email_address.blank?
    errors.add(:email_address, 'is required if callback_url is blank') if callback_url.blank? && email_address.blank?
  end
end
