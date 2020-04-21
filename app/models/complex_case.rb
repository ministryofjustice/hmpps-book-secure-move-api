# frozen_string_literal: true

class ComplexCase < ApplicationRecord
  validates :key, presence: true
  validates :title, presence: true
end
