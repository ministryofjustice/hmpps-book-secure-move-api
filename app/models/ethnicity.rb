# frozen_string_literal: true

class Ethnicity < ApplicationRecord
  validates :code, presence: true
  validates :title, presence: true
end
