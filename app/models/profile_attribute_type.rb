# frozen_string_literal: true

class ProfileAttributeType < ApplicationRecord
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

  validates :description, presence: true
  validates :category, inclusion: { in: categories }
  validates :user_type, inclusion: { in: user_types }
end
