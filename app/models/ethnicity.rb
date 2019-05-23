# frozen_string_literal: true

class Ethnicity < ApplicationRecord
  validates :value, presence: true
end
