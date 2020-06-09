# frozen_string_literal: true

class AllocationComplexCase < ApplicationRecord
  validates :key, presence: true
  validates :title, presence: true
end
