# frozen_string_literal: true

class Gender < ApplicationRecord
  validates :title, presence: true
  validates :key, presence: true
end
