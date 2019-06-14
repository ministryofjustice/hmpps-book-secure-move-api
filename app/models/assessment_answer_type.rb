# frozen_string_literal: true

class AssessmentAnswerType < ApplicationRecord
  validates :title, presence: true
  validates :category, inclusion: { in: categories }

  enum category: {
    health: 'health',
    risk: 'risk',
    court_information: 'court_information',
    reasons_for_no_release: 'reasons_for_no_release'
  }
end
