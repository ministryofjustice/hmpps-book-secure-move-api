# frozen_string_literal: true

class Framework < ApplicationRecord
  validates :name, presence: true
  validates :version, presence: true
  validates :name, uniqueness: { scope: :version }

  has_many :framework_questions
  has_many :person_escort_records
  has_many :youth_risk_assessments

  scope :versioned, -> { order(version: :desc) }
end
