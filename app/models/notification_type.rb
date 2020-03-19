# frozen_string_literal: true

class NotificationType < ApplicationRecord
  WEBHOOK = 'webhook'
  EMAIL = 'email'

  has_many :notifications, dependent: :destroy
  validates :title, presence: true
end
