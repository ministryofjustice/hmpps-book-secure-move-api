class Subscription < ApplicationRecord
  has_many :notifications, dependent: :restrict_with_error
  belongs_to :supplier

  validates :supplier, presence: true
  validates :callback_url, url: true, presence: true
end
