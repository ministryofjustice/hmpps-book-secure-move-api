# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :locations
  has_many :profiles

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :move_supported, inclusion: { in: [true, false] }
end
