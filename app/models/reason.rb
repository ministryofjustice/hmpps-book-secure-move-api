# frozen_string_literal: true

class Reason < ApplicationRecord
  validates :title, presence: true
  validates :key, presence: true
end
