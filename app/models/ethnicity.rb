# frozen_string_literal: true

class Ethnicity < ApplicationRecord
  validates :key, presence: true
  validates :title, presence: true
end
