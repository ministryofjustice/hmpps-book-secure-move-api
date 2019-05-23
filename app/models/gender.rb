# frozen_string_literal: true

class Gender < ApplicationRecord
  validates :title, presence: true
end
