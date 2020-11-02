# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :locations
  has_many :profiles

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :move_supported, presence: true

  def self.build_from_nomis(booking_details)
    new(
      key: booking_details[:category_code],
      title: booking_details[:category],
      move_supported: Move::UNSUPPORTED_PRISONER_CATEGORIES.exclude?(booking_details[:category_code]),
    )
  end
end
