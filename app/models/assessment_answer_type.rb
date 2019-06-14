# frozen_string_literal: true

class AssessmentAnswerType < ApplicationRecord
  validates :title, presence: true

  enum category: {
    health: 'health',
    risk: 'risk',
    court: 'court',
    reasons_for_no_release: 'reasons_for_no_release'
  }

  validates :category, inclusion: { in: categories }
end
