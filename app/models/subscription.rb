class Webhook < ApplicationRecord
  has_many :notifications, dependent: :restrict_with_error
  belongs_to :supplier

  validates :callback, url: true, presence: true
end
