# frozen_string_literal: true

class AssessmentAnswerType < ApplicationRecord
  validates :description, presence: true
  validates :category, presence: true
  validates :user_type, presence: true

  enum category: {
    health: 'health',
    risk: 'risk',
    court_information: 'court_information',
    reasons_for_no_release: 'reasons_for_no_release'
  }

  enum user_type: {
    prison: 'prison',
    police: 'police'
  }
end
