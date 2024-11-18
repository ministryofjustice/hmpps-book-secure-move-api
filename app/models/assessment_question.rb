# frozen_string_literal: true

class AssessmentQuestion < ApplicationRecord
  validates :key, presence: true
  validates :title, presence: true

  enum :category, {
    health: 'health',
    risk: 'risk',
    court: 'court',
  }

  validates :category, inclusion: { in: categories }
end
