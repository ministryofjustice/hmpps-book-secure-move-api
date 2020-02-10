# frozen_string_literal: true

class Subscription < ApplicationRecord
  include Discard::Model

  # NB: we should not be destroying subscriptions if they have notifications, instead call the discard! method
  has_many :notifications, dependent: :restrict_with_error
  belongs_to :supplier

  validates :supplier, presence: true
  validates :callback_url, url: true, presence: true

  def kept?
    !discarded?
  end

  def secret=(sekret)
    write_attribute(:encrypted_secret, Encryptor.encrypt(sekret))
  end

  def secret
    Encryptor.decrypt(encrypted_secret)
  end
end
