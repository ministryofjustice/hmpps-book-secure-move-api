# frozen_string_literal: true

class Nationality < ApplicationRecord
  validates :key, presence: true
  validates :title, presence: true
end
